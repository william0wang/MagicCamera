//
//  Network.swift
//  MagicCamera
//
//  Created by William on 2021/4/22.
//

import Foundation
import Alamofire

extension DispatchTime: ExpressibleByIntegerLiteral {
    public init(integerLiteral value: Int) {
        self = DispatchTime.now() + .seconds(value)
    }
}

func GetData(_ url:String,  callback:@escaping (Data?)->Void) {
    let session = URLSession.shared
    var request = URLRequest(url: URL(string: url)!)
    request.httpMethod = "GET"
    
    let task = session.dataTask(with: request ) { (data, response, error) in
        
        if let httpStatus = response as? HTTPURLResponse{
             if httpStatus.statusCode != 200 {
                debugPrint("statusCode should be 200, but is \(httpStatus.statusCode)")
                return
            }
        }
        callback(data)
    }

    task.resume()
}


struct Network {
    // static func GetConfig() -> Any? {
    //     let semaphore = DispatchSemaphore(value: 0)
    //     var result:Any?

    //     GetData(DefaultsKeys.ConfigUrl) {data in
    //         if (data == nil) {
    //             return
    //         }

    //         result = try? JSONSerialization.jsonObject(with: data!, options: [])
    //         semaphore.signal()
    //     }

    //     _ = semaphore.wait(timeout: 5)
    //     debugPrint(result)

    //     return result
    // }
}
