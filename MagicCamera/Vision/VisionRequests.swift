//
//  VisionRequests.swift
//  Mask
//
//  Created by 間嶋大輔 on 2020/04/28.
//  Copyright © 2020 daisuke. All rights reserved.
//

import AVFoundation
import Vision
import UIKit
import Photos
import AVKit
import BBMetalImage

typealias CompletionHandle = ((_ image: UIImage) -> ())
typealias GenderHandle = ((_ male: Bool) -> ())

public class CoreMLUtils {
    let lockFx = NSLock()
    let lockCompile = NSLock()
    
    private func doRequest(uiImage: UIImage, name: String, model: VNCoreMLModel
                           , completionHandler: @escaping CompletionHandle, offsets: [CGPoint] = []) {
        let orientation = uiImage.imageOrientation
        var uImage = uiImage
        if name.hasPrefix("attgan_") {
            uImage = uiImage.resized(to: CGSize(width: 384, height: 384))
        } else {
            uImage = uiImage.resized(to: CGSize(width: 256, height: 256))
        }
        let image = CIImage(image: uImage)
        let weakSelf = self
        
        let coreMLRequest = VNCoreMLRequest(model: model) {request,error in
            let result = request.results?.first as! VNCoreMLFeatureValueObservation
            let multiArray = result.featureValue.multiArrayValue
            var axes: (Int, Int, Int)?
            switch name {
            case "warpgan8", "chosoda8", "cpaprika8", "chayao8", "ugatit8":
                axes = (3,1,2)
                break
            case "attgan_young", "attgan_old", "attgan_blond_hair", "attgan_brown_hair", "attgan_mustache", "attgan_male":
                axes = (1,2,3)
                break
            default:
                axes = nil
            }
            let cgImage = multiArray?.cgImage(min: -1, max: 1, channel: nil, axes: axes)
            if(cgImage == nil ) {
                completionHandler(uiImage)
                weakSelf.lockFx.unlock()
                return
            }
            let out = UIImage(cgImage: cgImage!, scale: 1.0, orientation: orientation)//.resized(to: CGSize(width: 256, height: 256))
            
            var m = Model.anime_noise3_scale2x
            switch name {
            case "attgan_young", "attgan_old", "attgan_blond_hair", "attgan_brown_hair", "attgan_mustache", "attgan_male":
                m = Model.photo_noise1_scale2x
                break
            case "warpgan8":
                m = Model.photo_noise3_scale2x
                break
            case "hayao", "paprika":
                m = Model.anime_noise1_scale2x
                break
            default:
                if name.starts(with: "photo2cartoon")  {
                    m = Model.anime_noise1_scale2x
                }
                break
            }
            let outimage = Waifu2x.run(out, model: m)
            if !offsets.isEmpty {
                let bgout = self.doBackground(name.replacingOccurrences(of: "photo2cartoon_", with: ""), image: outimage ?? out, offsets:offsets)
                completionHandler(bgout)
            } else {
                completionHandler(outimage ?? out)
            }
            weakSelf.lockFx.unlock()
        }
        let handler = VNImageRequestHandler(ciImage: image!,options: [:])
        DispatchQueue.global(qos: .userInitiated).async {
            try? handler.perform([coreMLRequest])
        }
    }
    
    private func doRequestImage(uiImage: UIImage, name: String, model: VNCoreMLModel
                           , completionHandler: @escaping CompletionHandle) {
//        let orientation = uiImage.imageOrientation
        var uImage = uiImage
        if name != "style_pointillism8" && name != "style_starry_night8" {
            uImage = uiImage.resized(to: CGSize(width: 256, height: 256))
        }
        let image = CIImage(image: uImage)
        let weakSelf = self
        let coreMLRequest = VNCoreMLRequest(model: model) {request,error in
            guard let results = request.results as? [VNPixelBufferObservation] else {
                completionHandler(uiImage)
                weakSelf.lockFx.unlock()
                return
            }

            guard let observation = results.first else {
                completionHandler(uiImage)
                weakSelf.lockFx.unlock()
                return
            }
            
            guard let out = UIImage(pixelBuffer: observation.pixelBuffer) else {
                completionHandler(uiImage)
                weakSelf.lockFx.unlock()
                return
            }
            completionHandler(out)
            weakSelf.lockFx.unlock()
        }
        let handler = VNImageRequestHandler(ciImage: image!,options: [:])
        DispatchQueue.global(qos: .userInitiated).async {
            try? handler.perform([coreMLRequest])
        }
    }
    
    func getGender(face: FaceInfo, completionHandler: @escaping GenderHandle) {
        guard let model = loadModel(name: "gender4", face:face) else {
            completionHandler(false)
            return
        }
        let coreMLRequest = VNCoreMLRequest(model: model) {request,error in
            let result = request.results?.first as! VNClassificationObservation
            if result.identifier == "Male" {
                completionHandler(true)
            } else {
                completionHandler(false)
            }
        }
        let image = CIImage(image: face.image.resized(to: CGSize(width: 227, height: 227)))
        let handler = VNImageRequestHandler(ciImage: image!,options: [:])
        DispatchQueue.global(qos: .userInitiated).async {
            try? handler.perform([coreMLRequest])
        }
    }
    
    func DoFX(name: String, face: FaceInfo, completionHandler: @escaping CompletionHandle) {
        self.lockFx.lock()
        
        if face.IsFace && name.hasPrefix("attgan_") {
            getGender(face: face) { male in
                face.Male = male
                guard let model = self.loadModel(name: name, face:face) else {
                    completionHandler(face.image)
                    self.lockFx.unlock()
                    return
                }
                var faceImage = face.image
                
                let beauty = self.doAttganPreFilter(faceImage)
                if beauty != nil {
                    faceImage = beauty!
                }
                let segment = self.doSegment(image: faceImage)
                if segment != nil {
                    faceImage = segment!.image
                }
                self.doRequest(uiImage: faceImage, name:name, model: model, completionHandler: completionHandler)
            }
        } else {
            guard let model = loadModel(name: name, face:face) else {
                completionHandler(face.image)
                self.lockFx.unlock()
                return
            }
            var faceImage = face.image
            if name.hasPrefix("style_") {
                faceImage = self.doStylePreFilter(faceImage)
                doRequestImage(uiImage: faceImage, name:name, model: model, completionHandler: completionHandler)
            } else {
                let beauty = self.doCartoonPreFilter(faceImage)
                if beauty != nil {
                    faceImage = beauty!
                }
                if name.starts(with: "photo2cartoon")  {
                    let segment = doSegment(image: faceImage)
                    if segment != nil {
                        faceImage = segment!.image
                    }
                    if name.starts(with: "photo2cartoon_") {
                        doRequest(uiImage: faceImage, name:name, model: model, completionHandler: completionHandler, offsets: segment!.offsets)
                        return
                    }
                }
                doRequest(uiImage: faceImage, name:name, model: model, completionHandler: completionHandler)
            }
        }
    }
    
    
    private func loadMlModel(name: String) -> MLModel? {
        do {
            switch name {
            case "hayao":
                return try hayao(configuration: MLModelConfiguration()).model
            case "paprika":
                return try paprika(configuration: MLModelConfiguration()).model
            case "chayao8":
                return try chayao8(configuration: MLModelConfiguration()).model
            case "cpaprika8":
                return try cpaprika8(configuration: MLModelConfiguration()).model
            case "chosoda8":
                return try chosoda8(configuration: MLModelConfiguration()).model
            case "warpgan8":
                return try warpgan8(configuration: MLModelConfiguration()).model
            case "gender4":
                return try gender4(configuration: MLModelConfiguration()).model
            case "style_pointillism8":
                return try style_pointillism8(configuration: MLModelConfiguration()).model
            case "style_starry_night8":
                return try style_starry_night8(configuration: MLModelConfiguration()).model
            case "style_udnie", "style_wave", "style_rain_princess", "style_la_muse", "style_shipwreck_minotaur", "style_the_scream":
                return try style_transfer16(configuration: MLModelConfiguration()).model
            case "attgan_young", "attgan_old", "attgan_blond_hair", "attgan_brown_hair", "attgan_mustache", "attgan_male" :
                return try attgan16(configuration: MLModelConfiguration()).model
            default:
                if name.starts(with: "photo2cartoon")  {
                    return try photo2cartoon(configuration: MLModelConfiguration()).model
                }
                return nil
            }
        } catch {
            debugPrint("Unexpected error: \(error).")
        }
        return nil
    }

    private func doAttganPreFilter(_ image: UIImage) -> UIImage? {
        // Set up image source
        let imageSource = BBMetalStaticImageSource(image: image)
        // Set up filter chain
        // Make last filter run synchronously
        
        let out = BBMetalBeautyFilter(distanceNormalizationFactor: 4, stepOffset: 4, edgeStrength: 1, smoothDegree: 0.2)
        imageSource
            .add(consumer: BBMetalContrastFilter(contrast: 1.8))
            .add(consumer: BBMetalBrightnessFilter(brightness: 0.02))
            .add(consumer: out)
            .runSynchronously = true

        // Start processing
        imageSource.transmitTexture()
        
        let img = out.outputTexture?.bb_image
        if img == nil {
            return image
        }
        
        // Get filtered image
        return img//fleeting(image: img!)
    }
    
    private func doStylePreFilter(_ image: UIImage) -> UIImage {
        let filter = MTFilterManager.shared.allFilters[0].init()
        return mtFilterImage(image, filter:filter)
    }
    
    private func doCartoonPreFilter(_ image: UIImage) -> UIImage? {
        // Set up image source
        let imageSource = BBMetalStaticImageSource(image: image)
        // Set up filter chain
        // Make last filter run synchronously
        
        let out = BBMetalBeautyFilter(distanceNormalizationFactor: 4, stepOffset: 4, edgeStrength: 1, smoothDegree: 0.2)
        imageSource
            .add(consumer: BBMetalContrastFilter(contrast: 1.8))
            .add(consumer: BBMetalExposureFilter(exposure: 0.15))
            .add(consumer: out)
            .runSynchronously = true

        // Start processing
        imageSource.transmitTexture()
        
        let img = out.outputTexture?.bb_image
        if img == nil {
            return image
        }
        
        // Get filtered image
        return img//fleeting(image: img!)
    }
    
    private func loadModel(name: String, face: FaceInfo? = nil) -> VNCoreMLModel? {
        do {
            guard let mlmodel = loadMlModel(name: name) else {
                return nil
            }
            
            let model = try VNCoreMLModel(for: mlmodel)
            if !name.hasPrefix("attgan_") && !name.hasPrefix("style_"){
                return model
            }
            switch name {
            case "style_la_muse":
                model.featureProvider = StyleTransferProvider(style: StyleTransferProvider.Style.LaMuse)
                break
            case "style_rain_princess":
                model.featureProvider = StyleTransferProvider(style: StyleTransferProvider.Style.RainPrincess)
                break
            case "style_udnie":
                model.featureProvider = StyleTransferProvider(style: StyleTransferProvider.Style.Udnie)
                break
            case "style_wave":
                model.featureProvider = StyleTransferProvider(style: StyleTransferProvider.Style.Wave)
                break
            case "style_shipwreck_minotaur":
                model.featureProvider = StyleTransferProvider(style: StyleTransferProvider.Style.TheShipwreckOfTheMinotaur)
                break
            case "style_the_scream":
                model.featureProvider = StyleTransferProvider(style: StyleTransferProvider.Style.TheScream)
                break
            case "attgan_young":
                model.featureProvider = AttGanStyleProvider(style: AttGanStyleProvider.Style.Young, face: face)
                break
            case "attgan_old":
                model.featureProvider = AttGanStyleProvider(style: AttGanStyleProvider.Style.Old, face: face)
                break
            case "attgan_blond_hair":
                model.featureProvider = AttGanStyleProvider(style: AttGanStyleProvider.Style.Blond_Hair, face: face)
                break
            case "attgan_brown_hair":
                model.featureProvider = AttGanStyleProvider(style: AttGanStyleProvider.Style.Brown_Hair, face: face)
                break
            case "attgan_mustache":
                model.featureProvider = AttGanStyleProvider(style: AttGanStyleProvider.Style.Mustache, face: face)
                break
            case "attgan_male":
                model.featureProvider = AttGanStyleProvider(style: AttGanStyleProvider.Style.MaleFeMale, face: face)
                break
            default:
                break
            }
            return model
        } catch {
            debugPrint("Unexpected error: \(error).")
        }
        return nil
    }

    struct RGBA32: Equatable {
        private var color: UInt32

        var redComponent: UInt8 {
            return UInt8((color >> 24) & 255)
        }

        var greenComponent: UInt8 {
            return UInt8((color >> 16) & 255)
        }

        var blueComponent: UInt8 {
            return UInt8((color >> 8) & 255)
        }

        var alphaComponent: UInt8 {
            return UInt8((color >> 0) & 255)
        }        

        init(red: UInt8, green: UInt8, blue: UInt8, alpha: UInt8) {
            let red   = UInt32(red)
            let green = UInt32(green)
            let blue  = UInt32(blue)
            let alpha = UInt32(alpha)
            color = (red << 24) | (green << 16) | (blue << 8) | (alpha << 0)
        }

        static let red     = RGBA32(red: 255, green: 0,   blue: 0,   alpha: 255)
        static let green   = RGBA32(red: 0,   green: 255, blue: 0,   alpha: 255)
        static let blue    = RGBA32(red: 0,   green: 0,   blue: 255, alpha: 255)
        static let white   = RGBA32(red: 255, green: 255, blue: 255, alpha: 255)
        static let black   = RGBA32(red: 0,   green: 0,   blue: 0,   alpha: 255)
        static let magenta = RGBA32(red: 255, green: 0,   blue: 255, alpha: 255)
        static let yellow  = RGBA32(red: 255, green: 255, blue: 0,   alpha: 255)
        static let cyan    = RGBA32(red: 0,   green: 255, blue: 255, alpha: 255)

        static let bitmapInfo = CGImageAlphaInfo.premultipliedLast.rawValue | CGBitmapInfo.byteOrder32Little.rawValue

        static func ==(lhs: RGBA32, rhs: RGBA32) -> Bool {
            return lhs.color == rhs.color
        }
    }
}
