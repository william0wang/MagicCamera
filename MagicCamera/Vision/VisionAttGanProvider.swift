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
    
    class AttGanStyleProvider: MLFeatureProvider {
        enum Style: Int {
            case Young = 0
            case Old = 1
            case Black_Hair = 2
            case Blond_Hair = 3
            case Brown_Hair = 4
            case Mustache = 5
            case MaleFeMale = 6
        }
        // 0.Bald 1.Bangs 2.Black_Hair 3.Blond_Hair 4.Brown_Hair 5.Bushy_Eyebrows
        // 6.Eyeglasses 7.Male 8.Mouth_Slightly_Open 9.Mustache 10.No_Beard Pale_Skin 11.Young
        var style: [Float] = [ -0.5, 0, 0.5, -0.5, -0.5, -0.5, -0.5, -0.5, -0.5, -0.5,  0.5, -0.5, 0.5]
        public init(style: Style, face:FaceInfo? = nil) {
            if face == nil {
                return
            }
            
            let f = face!
            if f.IsFace {
                if f.Male {
                    self.style[7] = 0.5
                }
                if f.Smile {
                    self.style[8] = 0.5
                }
            }
            
            switch style {
            case Style.Young:
                self.style[12] = 1.0
                break
            case Style.Old:
                self.style[12] = -1.0
                break
            case Style.Black_Hair:
                self.style[2] = 0.5
                self.style[3] = -0.5
                self.style[4] = -0.5
                break
            case Style.Blond_Hair:
                self.style[2] = -0.5
                self.style[3] = 0.5
                self.style[4] = -0.5
                break
            case Style.Brown_Hair:
                self.style[2] = -0.5
                self.style[3] = -0.5
                self.style[4] = 0.5
                break
            case Style.Mustache:
                self.style[9] = 0.8
                self.style[10] = -0.5
                break
            case Style.MaleFeMale:
                if f.Male {
                    self.style[7] = -0.9
                } else {
                    self.style[7] = 0.9
                }
                break
            }
        }

        var featureNames: Set<String> {
            return Set(["style", "generator/b_"])
        }

        func featureValue(for featureName: String) -> MLFeatureValue? {
            do {
                switch featureName {
                case "style", "generator/b_":
                    let mlArray = try MLMultiArray(shape: [1, 13], dataType: MLMultiArrayDataType.float32)
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
