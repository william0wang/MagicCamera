//
//  ModelFactory.swift
//  waifu2x-ios
//
//  Created by 谢宜 on 2017/11/5.
//  Copyright © 2017年 xieyi. All rights reserved.
//

import Foundation
import CoreML

fileprivate class Dummy: Any {
}

public enum Model: String {
    case anime_noise1_scale2x = "up_anime_noise1_scale2x_model"
    case anime_noise3_scale2x = "up_anime_noise3_scale2x_model"
    case photo_noise1_scale2x = "up_photo_noise1_scale2x_model"
    case photo_noise3_scale2x = "up_photo_noise3_scale2x_model"
    // For the convience of unit test
    static let all: [Model] = [.anime_noise1_scale2x, .anime_noise3_scale2x,
                             .photo_noise1_scale2x, .photo_noise3_scale2x]
    public func getMLModel() -> MLModel {
        switch self.rawValue {
        case "up_anime_noise1_scale2x_model":
            return try! up_anime_noise1_scale2x_model(configuration: MLModelConfiguration()).model
        case "up_anime_noise3_scale2x_model":
            return try!  up_anime_noise3_scale2x_model(configuration: MLModelConfiguration()).model
        case "up_photo_noise3_scale2x_model":
            return try! up_photo_noise3_scale2x_model(configuration: MLModelConfiguration()).model
        default:
            return try! up_photo_noise1_scale2x_model(configuration: MLModelConfiguration()).model
        }
    }
}
