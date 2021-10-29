//
//  Filter.swift
//  MagicCamera
//
//  Created by William on 2020/12/25.
//

import AVFoundation
import Vision
import UIKit
import GPUImage

extension CoreMLUtils {
    func DoFaceThin(uiImage: UIImage, completionHandler: @escaping CompletionHandle) {
        let image = CIImage(image: uiImage)
        let weakSelf = self
        let width = uiImage.size.width
        let height = uiImage.size.height
        
        let faceRequest = VNDetectFaceLandmarksRequest() { request, error in
            guard let results = request.results as? [VNFaceObservation] else {
                completionHandler(uiImage)
                weakSelf.lockFx.unlock()
                return
            }
            let face = results.first
            if(face == nil || face!.landmarks == nil || face!.landmarks!.faceContour == nil) {
                completionHandler(uiImage)
                weakSelf.lockFx.unlock()
                return
            }
            guard let boundingRect = face?.boundingBox else {
                completionHandler(uiImage)
                weakSelf.lockFx.unlock()
                return
            }

            var boundingBox = CGRect(x:CGFloat(boundingRect.origin.x * width),
                                     y:CGFloat(height - ((boundingRect.origin.y + boundingRect.size.height) * height)),
                                     width: CGFloat(boundingRect.size.width * width),
                                     height: CGFloat(boundingRect.size.height * height))
            
            var points: [CGPoint] = []
            var toPoints: [CGPoint] = []
            for point in face!.landmarks!.faceContour!.normalizedPoints {
               let p = CGPoint(x: CGFloat(point.x * boundingBox.width + boundingBox.origin.x),
                               y: CGFloat((1.0 - point.y) * boundingBox.height + boundingBox.origin.y))
                points.append(p)
                toPoints.append(p)
            }
            
            for i in stride(from: 0, to: Int(height) ,by: 80) {
                let p1 = CGPoint(x: 0, y:CGFloat(i))
                let p2 = CGPoint(x: width, y:CGFloat(i))
                points.append(p1)
                toPoints.append(p1)
                points.append(p2)
                toPoints.append(p2)
            }
            let bottomLeft = CGPoint(x: 0, y: height)
            let bottomRight = CGPoint(x: width, y: height)
            points.append(bottomLeft)
            toPoints.append(bottomLeft)
            points.append(bottomRight)
            toPoints.append(bottomRight)
            
            for index in 1...6 {
                let idx1 = 8 - index
                let idx2 = 8 + index
                
                let w = points[idx1].x - points[idx2].x
                
                let padding = w/CGFloat(8+index*2)/2
                
                toPoints[idx1].x -= padding
                toPoints[idx2].x += padding
            }
            
            let thinFaceOperation = ThinFaceOperation()
            thinFaceOperation.setupData(image: uiImage, landmarks: points, toPoints: toPoints)
            
            let imageInput = PictureInput(image: uiImage)
            
            let imageOutput = PictureOutput()
            imageOutput.imageAvailableCallback = { image in
                completionHandler(image)
                weakSelf.lockFx.unlock()
            }
            
            imageInput --> thinFaceOperation --> imageOutput
            imageInput.processImage(synchronously:true)
        }
        
        let handler = VNImageRequestHandler(ciImage: image!,options: [:])
        DispatchQueue.global(qos: .userInitiated).async {
            try? handler.perform([faceRequest])
        }
    }
}
