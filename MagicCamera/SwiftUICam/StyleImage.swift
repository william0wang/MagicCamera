//
//  StyleImage.swift
//  MagicCamera
//
//  Created by William on 2020/12/30.
//

import Foundation
import BBMetalImage
import GPUImage
import MetalPetal

func mtFilterImage(_ image: UIImage, filter: MTFilter) -> UIImage {
    let inputImage = MTIImage(cgImage: image.cgImage!, options: [.SRGB: false], isOpaque: true)
    filter.inputImage = inputImage
    do {
        let context = try MTIContext(device: MTLCreateSystemDefaultDevice()!)
        let cgImage = try context.makeCGImage(from: filter.outputImage!)
        return UIImage(cgImage: cgImage)
    } catch{
        debugPrint("Unexpected error: \(error).")
    }
    return image
}

func fleeting(image: UIImage) -> UIImage {
    
        // Set up image source
        let imageSource = BBMetalStaticImageSource(image: image)
        
        // Set up 3 filters to process image
        let gaussian = BBMetalGaussianBlurFilter(sigma: 10)
        let lookup1 = BBMetalLookupFilter(lookupTable: UIImage(named: "lookup_soft_elegance_1.png")!.bb_metalTexture!)
        let lookup2 = BBMetalLookupFilter(lookupTable: UIImage(named: "lookup_soft_elegance_2.png")!.bb_metalTexture!)
        let alphaBlend = BBMetalAlphaBlendFilter(mixturePercent:0.14)
        
        imageSource.add(consumer: lookup1)
            .add(consumer: gaussian)
            .runSynchronously = true
        imageSource.transmitTexture()
        
        guard let img1 = gaussian.outputTexture?.bb_image else {
            return image
        }
        imageSource.add(consumer: lookup1)
            .runSynchronously = true
        imageSource.transmitTexture()
        
        guard let img2 = lookup1.outputTexture?.bb_image else {
            return image
        }
        
        guard let img = alphaBlend.filteredImage(with: img2, img1) else {
            return image
        }
        
        guard let filteredImage = lookup2.filteredImage(with: img) else {
            return image
        }
        
        return filteredImage
}

func StyleImage(style: String, image: UIImage) -> UIImage {
    
    switch style {
    case "lomo":
        guard let filteredImage = BBMetalSketchFilter().filteredImage(with: image) else {
            return image
        }
        return filteredImage
    case "toon":
        guard let filteredImage = BBMetalToonFilter().filteredImage(with: image) else {
            return image
        }
        return filteredImage
    case "kuwahara":
        guard let filteredImage = BBMetalKuwaharaFilter(radius:6).filteredImage(with: image) else {
            return image
        }
        return filteredImage
    case "pixellate":
        guard let filteredImage = BBMetalPixellateFilter().filteredImage(with: image) else {
            return image
        }
        return filteredImage
    case "fleeting":
        return fleeting(image: image)
    case "hdr":
        guard let filteredImage = BBMetalLookupFilter(lookupTable: UIImage(named: "lookup_miss_etikate.png")!.bb_metalTexture!).filteredImage(with: image) else {
            return image
        }
        return filteredImage
    default:
        break
    }
    
    return image
}

