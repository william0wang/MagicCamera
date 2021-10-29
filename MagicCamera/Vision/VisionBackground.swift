//
//  VisionBackground.swift
//  MagicCamera
//
//  Created by William on 2021/5/25.
//

import Foundation
import Vision

extension CoreMLUtils {
    
    class SegmentInfo {
        public var image: UIImage
        public var offsets: [CGPoint] = []
        
        public init(_ image: UIImage, offsets: [CGPoint]) {
            self.image = image
            self.offsets = offsets
        }
    }

    func doSegment(image: UIImage) -> SegmentInfo? {
        do {
            let model = try DeepLabV3Int8LUT(configuration: MLModelConfiguration())
            
            let size = 513
            let nimage = image.resized(to: CGSize(width: size, height: size))
            let pixelBuffer = nimage.pixelBuffer(width: size, height: size)

            let result = try model.prediction(image: pixelBuffer!)
            let semanticPredictions = result.semanticPredictions

            let colorSpace       = CGColorSpaceCreateDeviceRGB()
            let width            = size
            let height           = size
            let bytesPerPixel    = 4
            let bitsPerComponent = 8
            let bytesPerRow      = bytesPerPixel * width
            let bitmapInfo       = RGBA32.bitmapInfo

            let context = try CGContext(data: nil, width: width, height: height, bitsPerComponent: bitsPerComponent,
                bytesPerRow: bytesPerRow, space: colorSpace, bitmapInfo: bitmapInfo)

            context!.draw(nimage.cgImage!, in: CGRect(x: 0, y: 0, width: width, height: height))

            let buffer = context!.data!
            let pixelBufferNew = buffer.bindMemory(to: RGBA32.self, capacity: width * height)
            
            var offsets: [CGPoint] = []

            for row in 0 ..< Int(height) {
                for column in 0 ..< Int(width) {
                    let offset = row * width + column
                    let label = Int8(truncating: semanticPredictions[offset])
                    if label != 0xF {
                        offsets.append(CGPoint(x: column, y: row))
                        pixelBufferNew[offset] = .white
                    }
                }
            }

            let outputCGImage = context!.makeImage()!
            let outputImage = UIImage(cgImage: outputCGImage, scale: image.scale, orientation: image.imageOrientation)

            return SegmentInfo(outputImage, offsets: offsets)
        } catch {
            debugPrint(error)
        }
        return nil
    }

    func doBackground(_ name: String, image: UIImage, offsets: [CGPoint]) -> UIImage {
        let size = 513
        let insize = image.size.width
        let cgSize = CGSize(width: size, height: size)
        
        guard let bgimg = UIImage(named: name + ".jpg")?.cgImage else {
            return image
        }
        
        guard let prov = bgimg.dataProvider else {
            return image
        }
        
        guard let pixelData = prov.data else {
            return image
        }
        
        let data:UnsafePointer<UInt8> = CFDataGetBytePtr(pixelData)

        let nimage = image.resized(to: cgSize)
        
        let colorSpace       = CGColorSpaceCreateDeviceRGB()
        let width            = size
        let height           = size
        let bytesPerPixel    = 4
        let bitsPerComponent = 8
        let bytesPerRow      = bytesPerPixel * width
        let bitmapInfo       = RGBA32.bitmapInfo
        guard let context = try CGContext(data: nil, width: width, height: height, bitsPerComponent: bitsPerComponent,
                                           bytesPerRow: bytesPerRow, space: colorSpace, bitmapInfo: bitmapInfo) else {
            return image
        }

        context.draw(nimage.cgImage!, in: CGRect(x: 0, y: 0, width: width, height: height))

        let buffer = context.data!
        let pixelBufferNew = buffer.bindMemory(to: RGBA32.self, capacity: width * height)
        
        for idx in 0 ..< offsets.count {
            let point = offsets[idx]
            let offset = Int(point.y) * width + Int(point.x)
            let offset2 = (Int(point.y) * width + Int(point.x)) * 4
            let r = data[offset2]
            let g = data[offset2+1]
            let b = data[offset2+2]
            let a = data[offset2+3]
            pixelBufferNew[offset] = RGBA32(red: r, green: g, blue: b, alpha: a)
        }

        guard let outputCGImage = context.makeImage() else {
            return image
        }
        
        let outputImage = UIImage(cgImage: outputCGImage).resized(to: CGSize(width: insize, height: insize))
        
        //ImageSaver.init().writeToPhotoAlbum(image: outputImage)

        return outputImage
    }
}
