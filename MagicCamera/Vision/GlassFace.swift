//
//  Filter.swift
//  MagicCamera
//
//  Created by William on 2020/12/25.
//

import AVFoundation
import Vision
import UIKit
import BBMetalImage

extension CoreMLUtils {
    func DoGlassFace(uiImage: UIImage, cartoon: UIImage, completionHandler: @escaping CompletionHandle) {
        let width = cartoon.size.width
        let height = cartoon.size.height
        let face = CIImage(image: uiImage.resized(to: CGSize(width: width, height: height)))
        let weakSelf = self
        
        let faceRequest = VNDetectFaceLandmarksRequest() { request, error in
            guard let results = request.results as? [VNFaceObservation] else {
                completionHandler(cartoon)
                weakSelf.lockFx.unlock()
                return
            }
            let face = results.first
            if(face == nil || face!.landmarks == nil || face!.landmarks!.faceContour == nil) {
                completionHandler(cartoon)
                weakSelf.lockFx.unlock()
                return
            }
            
            guard let boundingRect = face?.boundingBox else {
                completionHandler(cartoon)
                weakSelf.lockFx.unlock()
                return
            }
            
            let boundingBox = CGRect(x:CGFloat(boundingRect.origin.x * width),
                                     y:CGFloat(height - ((boundingRect.origin.y + boundingRect.size.height) * height)),
                                     width: CGFloat(boundingRect.size.width * width),
                                     height: CGFloat(boundingRect.size.height * height))
            
            guard let landmarks = face?.landmarks else {
                completionHandler(cartoon)
                weakSelf.lockFx.unlock()
                return
            }
            
            guard let left = landmarks.leftPupil?.normalizedPoints else {
                completionHandler(cartoon)
                weakSelf.lockFx.unlock()
                return
            }
            
            guard let right = landmarks.rightPupil?.normalizedPoints else {
                completionHandler(cartoon)
                weakSelf.lockFx.unlock()
                return
            }
            
            if left.isEmpty {
                completionHandler(cartoon)
                weakSelf.lockFx.unlock()
                return
            }
            
            if right.isEmpty {
                completionHandler(cartoon)
                weakSelf.lockFx.unlock()
                return
            }
            
            let lp = left[0]
            let rp = right[0]
            
            let leftEye = CGPoint(x: CGFloat(lp.x * boundingBox.width + boundingBox.origin.x),
                            y: CGFloat((1.0 - lp.y) * boundingBox.height + boundingBox.origin.y))
            
            let rightEye = CGPoint(x: CGFloat(rp.x * boundingBox.width + boundingBox.origin.x),
                            y: CGFloat((1.0 - rp.y) * boundingBox.height + boundingBox.origin.y))
            
            let sx = width/512
            let leftGlass = CGPoint(x:165*sx, y:245*sx)
            let rightGlass = CGPoint(x:350*sx, y:245*sx)
            
            let ew = rightEye.x - leftEye.x
            let eh = rightEye.y - leftEye.y
            let el = sqrt(pow(ew, 2) + pow(eh, 2)) // 眼睛宽度
            let angleN = atan(eh / ew)  // 脸的角度
            
            let gl = rightGlass.x - leftGlass.x // 眼镜宽度
            let scaling = el / gl // 缩放比例
            
//            let x = leftGlass.x * scaling
//            let y = leftGlass.y * scaling
//            let cx = CGFloat(0)
//            let cy = CGFloat(0)
//
//            let lx = (x-cx)*cos(angleN) + (y-cy)*sin(angleN)+cx
//            let ly = (y-cy)*cos(angleN) - (x-cx)*sin(angleN)+cy

            guard let imageGlass = UIImage(named: "glass.png")?.resized(to: CGSize(width: width, height: width)) else {
                completionHandler(cartoon)
                weakSelf.lockFx.unlock()
                return
            }
            
            let t1 = CGAffineTransform(scaleX: scaling, y: scaling)
            let t2 = CGAffineTransform(rotationAngle: angleN)
            
            let leftNew = leftGlass.applying(t1.concatenating(t2))
            
            let tx = leftEye.x - leftNew.x
            let ty = leftEye.y - leftNew.y
            debugPrint("eyes",leftEye, leftNew, tx, ty, angleN)
            
            let t3 = CGAffineTransform(translationX: tx, y: ty)
            let transform = t1.concatenating(t2).concatenating(t3)
            
            guard let glass = BBMetalTransformFilter(transform: transform, fitSize: false).filteredImage(with: imageGlass) else {
                completionHandler(cartoon)
                weakSelf.lockFx.unlock()
                return
            }
            
//            let save = ImageSaver.init()
//            save.writeToPhotoAlbum(image: glass)
            
            guard let out = BBMetalAlphaBlendFilter(mixturePercent: 1).filteredImage(with: cartoon, glass) else {
                completionHandler(cartoon)
                weakSelf.lockFx.unlock()
                return
            }
            
            completionHandler(out)
            weakSelf.lockFx.unlock()
        }
        
        let handler = VNImageRequestHandler(ciImage: face!,options: [:])
        DispatchQueue.global(qos: .userInitiated).async {
            try? handler.perform([faceRequest])
        }
    }
}
