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
    func DoFaceOld(uiImage: UIImage, completionHandler: @escaping CompletionHandle) {
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
            if(face == nil ) {
                completionHandler(uiImage)
                weakSelf.lockFx.unlock()
                return
            }
            guard let boundingRect = face?.boundingBox else {
                completionHandler(uiImage)
                weakSelf.lockFx.unlock()
                return
            }

            var landmarkRegions: [VNFaceLandmarkRegion2D] = []
            do {
                try landmarkRegions.append(face!.landmarks!.nose!)
//                try landmarkRegions.append(face!.landmarks!.noseCrest!)
//                try landmarkRegions.append(face!.landmarks!.medianLine!)
                try landmarkRegions.append(face!.landmarks!.leftEye!)
                try landmarkRegions.append(face!.landmarks!.leftPupil!)
                try landmarkRegions.append(face!.landmarks!.leftEyebrow!)
                try landmarkRegions.append(face!.landmarks!.rightEye!)
                try landmarkRegions.append(face!.landmarks!.rightPupil!)
                try landmarkRegions.append(face!.landmarks!.rightEyebrow!)
                try landmarkRegions.append(face!.landmarks!.innerLips!)
                try landmarkRegions.append(face!.landmarks!.outerLips!)
                try landmarkRegions.append(face!.landmarks!.faceContour!)
            } catch {
                completionHandler(uiImage)
                weakSelf.lockFx.unlock()
                return
            }
            
            let boundingBox = CGRect(x:CGFloat(boundingRect.origin.x * width),
                                     y:CGFloat(height - ((boundingRect.origin.y + boundingRect.size.height) * height)),
                                     width: CGFloat(boundingRect.size.width * width),
                                     height: CGFloat(boundingRect.size.height * height))
            
            var points: [CGPoint] = []
            for faceLandmarkRegion in landmarkRegions {
                   for point in faceLandmarkRegion.normalizedPoints {
                       let p = CGPoint(x: CGFloat(point.x * boundingBox.width + boundingBox.origin.x),
                                       y: CGFloat((1.0 - point.y) * boundingBox.height + boundingBox.origin.y))
                    
                       points.append(p)
                   }
            }
            
//            debugPrint("boundingBox", boundingBox)
//            debugPrint("points", points)
            
            let oldFaceOperation = OldFaceOperation()
            oldFaceOperation.setupData(landmarks: points, inputSize: uiImage.size)
            
            let imageInput = PictureInput(image: uiImage)
            let overlayBlend = OverlayBlend()
            
            let imageOutput = PictureOutput()
            imageOutput.imageAvailableCallback = { image in
                completionHandler(BeautyFilter(image, light: true))
                weakSelf.lockFx.unlock()
            }
            
            imageInput --> overlayBlend --> imageOutput
            imageInput --> oldFaceOperation --> overlayBlend
            imageInput.processImage(synchronously:true)
        }
        
        let handler = VNImageRequestHandler(ciImage: image!,options: [:])
        DispatchQueue.global(qos: .userInitiated).async {
            try? handler.perform([faceRequest])
        }
    }
}
