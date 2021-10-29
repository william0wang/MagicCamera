//
//  Alamofire+Sync.swift
//  MagicCamera
//
//  Created by William on 2021/4/22.
//
import Foundation
import Alamofire

extension DataRequest {
    
    
    /**
     Wait for the request to finish then return the response value.
     
     - returns: The response.
     */
    public func response() -> AFDataResponse<Data?> {
        
        let semaphore = DispatchSemaphore(value: 0)
        var result: AFDataResponse<Data?>!
        
        self.response(queue: DispatchQueue.global(qos: .default)) { response in
            
            result = response
            semaphore.signal()
            
        }
        
        _ = semaphore.wait(timeout: DispatchTime.distantFuture)
        
        return result
    }
    
    /**
     Wait for the request to finish then return the response value.
     
     - parameter responseSerializer: The response serializer responsible for serializing the request, response,
     and data.
     - returns: The response.
     */
    public func response<T: DataResponseSerializerProtocol>(responseSerializer: T) -> AFDataResponse<T.SerializedObject> {
        
        let semaphore = DispatchSemaphore(value: 0)
        var result: AFDataResponse<T.SerializedObject>!
        
        self.response(queue: DispatchQueue.global(qos: .default), responseSerializer: responseSerializer) { response in
            
            result = response
            semaphore.signal()
            
        }
        
        _ = semaphore.wait(timeout: DispatchTime.distantFuture)
        
        return result
    }
    
    
    /**
     Wait for the request to finish then return the response value.
     
     - returns: The response.
     */
    public func responseData() -> AFDataResponse<Data> {
        return response(responseSerializer: DataResponseSerializer())
    }
    
    
    /**
     Wait for the request to finish then return the response value.
     
     - parameter options: The JSON serialization reading options. `.AllowFragments` by default.
     
     - returns: The response.
     */
    public func responseJSON(options: JSONSerialization.ReadingOptions = .allowFragments) -> AFDataResponse<Any> {
        return response(responseSerializer: JSONResponseSerializer(options: options))
    }
    
    
    /**
     Wait for the request to finish then return the response value.
     
     - parameter encoding: The string encoding. If `nil`, the string encoding will be determined from the
     server response, falling back to the default HTTP default character set,
     ISO-8859-1.
     
     - returns: The response.
     */
    public func responseString(encoding: String.Encoding? = nil) -> AFDataResponse<String> {
        return response(responseSerializer: StringResponseSerializer(encoding: encoding))
    }
}


extension DownloadRequest {
    /**
     Wait for the request to finish then return the response value.
     
     - returns: The response.
     */
    public func response() -> AFDownloadResponse<URL?> {
        
        let semaphore = DispatchSemaphore(value: 0)
        var result: AFDownloadResponse<URL?>!
        
        self.response(queue: DispatchQueue.global(qos: .default)) { response in
            
            result = response
            semaphore.signal()
            
        }
        
        _ = semaphore.wait(timeout: DispatchTime.distantFuture)
        
        return result
    }
    
    
    /**
     Wait for the request to finish then return the response value.
     
     - parameter responseSerializer: The response serializer responsible for serializing the request, response,
     and data.
     - returns: The response.
     */
    public func response<T: DownloadResponseSerializerProtocol>(responseSerializer: T) -> AFDownloadResponse<T.SerializedObject> {
        
        let semaphore = DispatchSemaphore(value: 0)
        var result: AFDownloadResponse<T.SerializedObject>!
        
        self.response(queue: DispatchQueue.global(qos: .background), responseSerializer: responseSerializer) { response in
            
            result = response
            semaphore.signal()
            
        }
        
        _ = semaphore.wait(timeout: DispatchTime.distantFuture)
        
        return result
    }
    
    
    /**
     Wait for the request to finish then return the response value.
     
     - returns: The response.
     */
    public func responseData() -> AFDownloadResponse<Data> {
        return response(responseSerializer: DataResponseSerializer())
    }
    
    /**
     Wait for the request to finish then return the response value.
     
     - parameter options: The JSON serialization reading options. `.AllowFragments` by default.
     
     - returns: The response.
     */
    public func responseJSON(options: JSONSerialization.ReadingOptions = .allowFragments) -> AFDownloadResponse<Any> {
        return response(responseSerializer: JSONResponseSerializer(options: options))
    }
    
    /**
     Wait for the request to finish then return the response value.
     
     - parameter encoding: The string encoding. If `nil`, the string encoding will be determined from the
     server response, falling back to the default HTTP default character set,
     ISO-8859-1.
     
     - returns: The response.
     */
    public func responseString(encoding: String.Encoding? = nil) -> AFDownloadResponse<String> {
        return response(responseSerializer: StringResponseSerializer(encoding: encoding))
    }
}
