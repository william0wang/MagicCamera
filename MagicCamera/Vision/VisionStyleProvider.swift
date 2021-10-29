//
//  VisionProvider.swift
//  MagicCamera
//
//  Created by William on 2021/1/8.
//

import Foundation
import Vision
import UIKit
import Photos
import AVKit

extension CoreMLUtils {
    /*
     la_muse
     rain_princess
     the_scream
     the_shipwreck_of_the_minotaur
     udnie
     wave
     */
    class StyleTransferProvider: MLFeatureProvider {
        enum Style: Int {
            case LaMuse = 0
            case RainPrincess = 1
            case TheScream = 2
            case TheShipwreckOfTheMinotaur = 3
            case Udnie = 4
            case Wave = 5
        }
        var style: [Double] = [ 0, 0, 0, 0, 0, 0]
        public init(style: Style) {
            self.style[style.rawValue] = 1
        }

        var featureNames: Set<String> {
            return Set(["index"])
        }

        func featureValue(for featureName: String) -> MLFeatureValue? {
            do {
                switch featureName {
                case "index":
                    let mlArray = try MLMultiArray(shape: [6], dataType: MLMultiArrayDataType.double)
                    for i in 0..<style.count {
                        mlArray[i] = NSNumber(value: style[i])
                    }
                    return MLFeatureValue(multiArray: mlArray)
                default:
                    return nil
                }
            } catch {
                debugPrint("AttGenStyleProvider Unexpected error: \(error).")
            }
            return nil
        }
    }
}
