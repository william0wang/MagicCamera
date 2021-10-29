//
//  FaceImage.swift
//  TestApp
//
//  Created by William on 2020/12/12.
//

import SwiftUI
import Foundation
import Vision
import BBMetalImage

extension SwiftUI.Color {
    init?(hex: String){
        let r, g, b, a: CGFloat

        if hex.hasPrefix("#") {
            let start = hex.index(hex.startIndex, offsetBy: 1)
            let hexColor = String(hex[start...])

            if hexColor.count == 6 {
                let scanner = Scanner(string: hexColor)
                var hexNumber: UInt64 = 0

                if scanner.scanHexInt64(&hexNumber) {
                    r = CGFloat((hexNumber & 0xff0000) >> 16) / 255
                    g = CGFloat((hexNumber & 0x00ff00) >> 8) / 255
                    b = CGFloat(hexNumber & 0x0000ff) / 255
                    a = 255 / 255

                    self.init(red: Double(r), green: Double(g), blue: Double(b))
                    _ = self.opacity(Double(a))
                    return
                }
            }
        }
        return nil
    }
}

public protocol CameraFxImage {
    mutating func didImageOk(_ image: UIImage)
    mutating func doFx(_ fx: String)
}

typealias DetectHandle = ((_ image: UIImage) -> ())

class ImageSaver: NSObject {
    private var action: (_ ok:Bool, _ error: Error?) -> Void
    
    public init(action: @escaping (_ ok:Bool, _ error: Error?) -> Void = {_,_  in }) {
        self.action = action
    }
    
    func writeToPhotoAlbum(image: UIImage) {
        UIImageWriteToSavedPhotosAlbum(image, self, #selector(saveError), nil)
    }

    @objc func saveError(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        DispatchQueue.main.async {
            if (error != nil) {
                self.action(false, error)
            } else {
                self.action(true, error)
            }
        }
    }
}

func corpFace2(_ image: UIImage, finishHandle: @escaping DetectHandle)
{
    guard let personImage = CIImage(image: image) else {
        return
    }
    
    personImage.oriented(CGImagePropertyOrientation(rawValue: UInt32(image.imageOrientation.rawValue))!)
    
    let requestHandle = VNImageRequestHandler(ciImage: personImage, options: [:])
    var baseRequest = VNImageBasedRequest()
    
    let completionHandle: VNRequestCompletionHandler = { request, error in
        guard let boxArr = request.results as? [VNFaceObservation] else { return }
        if (boxArr.count < 1) {
            return
        }
        
        var rect = convertRect(boxArr[0].boundingBox, image)
        
        rect.size.height = max(rect.size.height, rect.size.width)
        rect.size.width = rect.size.height
        let padding = rect.size.width/10
        rect = rect.insetBy(dx: -padding, dy: -padding) // Adds padding around the face so it's not so tightly cropped
//        rect = rect.offsetBy(dx: 0, dy: -padding*2/3 )
     
        let ciimage = personImage.cropped(to: rect)
        let maxSize = CGFloat(512)
        if (rect.size.width > maxSize && rect.size.height > maxSize) {
            if(rect.size.width > rect.size.height) {
                rect = CGRect(x: 0, y: 0, width: rect.size.width / rect.size.height * maxSize, height: maxSize)
            } else if (rect.size.height > rect.size.width) {
                rect = CGRect(x: 0, y: 0, width: maxSize, height: rect.size.height / rect.size.width * maxSize)
            } else {
                rect = CGRect(x: 0, y: 0, width: maxSize, height: maxSize)
            }
        }
        
        UIGraphicsBeginImageContextWithOptions(rect.size, false, image.scale)
        defer { UIGraphicsEndImageContext() }
        UIImage(ciImage: ciimage, scale: 1.0, orientation: image.imageOrientation).draw(in: CGRect(origin: .zero, size: rect.size))

        finishHandle(UIGraphicsGetImageFromCurrentImageContext() ?? image)
    }

    baseRequest = VNDetectFaceRectanglesRequest(completionHandler: completionHandle)
    DispatchQueue.global().async {
        do{
            try requestHandle.perform([baseRequest])
        }catch{
            debugPrint("Throws：\(error)")
        }
    }
}

fileprivate func convertRect(_ rectangleRect: CGRect, _ image: UIImage) -> CGRect {
    let imageSize = image.size
    let w = rectangleRect.width * imageSize.width
    let h = rectangleRect.height * imageSize.height
    let x = rectangleRect.minX * imageSize.width
    //该Y坐标与UIView的Y坐标是相反的
    let y = (1 - rectangleRect.minY) * imageSize.height - h
    return CGRect(x: x, y: y, width: w, height: h)
}

func corpImage(_ image: UIImage) -> UIImage
{
    let imageWidth = image.size.width
    let imageHeight = image.size.height
    let width = min(imageWidth, imageHeight)
    let height = width
    var origin = CGPoint()
    switch image.imageOrientation {
    case .right, .left, .leftMirrored, .rightMirrored:
        origin.x = (imageHeight - height)/2
        origin.y = (imageWidth - width)/2
        break
    default:
        origin.x = (imageWidth - width)/2
        origin.y = (imageHeight - height)/2
    }
    let size = CGSize(width: width, height: height)
    
    return image.crop(rect: CGRect(origin: origin, size: size))
}

func BeautyFilter(_ image : UIImage, light: Bool = false) -> UIImage {
    var smooth = Float(0.75)
    if light {
        smooth = 0.5
    }
    let filter = BBMetalBeautyFilter(distanceNormalizationFactor: 4, stepOffset: 4, edgeStrength: 1, smoothDegree: smooth)
    guard let filteredImage = filter.filteredImage(with: image) else {
        return image
    }
    return filteredImage
}

class FaceInfo {
    public var image: UIImage
    public var IsFace: Bool = false
    public var Smile: Bool = false
    public var Male: Bool = false
    
    public init(_ image: UIImage, isFace: Bool = false, smile:Bool = false) {
        self.image = image
        self.IsFace = isFace
        self.Smile = smile
    }
}

func corpFace(_ image: UIImage) -> FaceInfo
{
    var orientation: NSNumber {
           switch image.imageOrientation {
           case .up:            return 1
           case .upMirrored:    return 2
           case .down:          return 3
           case .downMirrored:  return 4
           case .leftMirrored:  return 5
           case .right:         return 6
           case .rightMirrored: return 7
           case .left:          return 8
           default:             return 0
           }
       }
    
    guard let personImage = CIImage(image: image) else {
        return FaceInfo(corpImage(image))
    }
    
    let accuracy = [CIDetectorAccuracy: CIDetectorAccuracyHigh]
    let faceDetector = CIDetector(ofType: CIDetectorTypeFace, context: nil, options: accuracy)
    // This will just take the first detected face but you can do something more sophisticated
    guard let face0 = faceDetector?.features(in: personImage, options: [CIDetectorImageOrientation: orientation, CIDetectorSmile:true]).first as? CIFaceFeature else {
        return FaceInfo(corpImage(image))
    }

    // Make the facial rect a square so it will mask nicely to a circle (may not be strictly necessary as `CIFaceFeature` bounds is typically a square)
    var rect = face0.bounds
    
    debugPrint("hasSmile", face0.hasSmile)
    
    let yc = rect.size.height/2 + rect.origin.y
    rect.size.height = min(image.size.width, image.size.height)
    rect.size.width = min(image.size.width, image.size.height)
    rect.origin.x = 0
    rect.origin.y = yc - rect.size.height*9/20
    if rect.origin.y < 0 {
        rect.origin.y = 0
    }
//    let padding = (rect.size.width - rect.size.height)/2
//    rect = rect.insetBy(dx: 0, dy: -padding) // Adds padding around the face so it's not so tightly cropped
//    rect = rect.offsetBy(dx: -rect.origin.x, dy: -padding)

    let ciimage = personImage.cropped(to: rect)
//    let maxSize = CGFloat(1080)
//    if (rect.size.width > maxSize && rect.size.height > maxSize) {
//        if(rect.size.width > rect.size.height) {
//            rect = CGRect(x: 0, y: 0, width: rect.size.width / rect.size.height * maxSize, height: maxSize)
//        } else if (rect.size.height > rect.size.width) {
//            rect = CGRect(x: 0, y: 0, width: maxSize, height: rect.size.height / rect.size.width * maxSize)
//        } else {
//            rect = CGRect(x: 0, y: 0, width: maxSize, height: maxSize)
//        }
//    }
     
    UIGraphicsBeginImageContextWithOptions(rect.size, false, image.scale)
    defer { UIGraphicsEndImageContext() }
    UIImage(ciImage: ciimage, scale: 1.0, orientation: image.imageOrientation).draw(in: CGRect(origin: .zero, size: rect.size))

    return FaceInfo(UIGraphicsGetImageFromCurrentImageContext() ?? corpImage(image), isFace: true, smile: face0.hasSmile)
}

func ImageToJpg(_ image: UIImage) -> Data? {
    let data = image.jpegData(compressionQuality: 0.8)
    return data
}

func JpgToImage(_ photoData: Data) -> UIImage {
    let dataProvider = CGDataProvider(data: photoData as CFData)
    let cgImageRef = CGImage(jpegDataProviderSource: dataProvider!,
                             decode: nil,
                             shouldInterpolate: true,
                             intent: CGColorRenderingIntent.defaultIntent)
    
    // TODO: implement imageOrientation
    // Set proper orientation for photo
    // If camera is currently set to front camera, flip image
    //          let imageOrientation = getImageOrientation()
    
    // For now, it is only right
    let image = UIImage(cgImage: cgImageRef!)
    
    return image
}

func loadImage(name: String, filter: MTFilter? = nil, resize: CGSize? = nil) -> Image {
//    debugPrint("loadImage", name)
    if filter == nil {
        return Image(uiImage: UIImage(named: name)!)
    }
    if resize == nil {
        return Image(uiImage: mtFilterImage(UIImage(named: name)!, filter: filter!))
    }
    return Image(uiImage: mtFilterImage(UIImage(named: name)!.resized(to: resize!), filter: filter!))
}
