//
//  PostData.swift
//  MagicCamera
//
//  Created by William on 2020/12/12.
//

import Foundation

func PostData(_ data: Data?, callback:@escaping (Data?)->Void) {
    let session = URLSession.shared
    let url = URL(string: "https://dev-face.51kfire.com:4443/")!

    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    request.httpBody = data
    
    let task = session.dataTask(with: request ) { (data, response, error) in
        
        if let httpStatus = response as? HTTPURLResponse{
             if httpStatus.statusCode != 200 {
                debugPrint("statusCode should be 200, but is \(httpStatus.statusCode)")
                return
            }
        }
        debugPrint("response = \(response)")
        callback(data)
    }

    task.resume()
}
