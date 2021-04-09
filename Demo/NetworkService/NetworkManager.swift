//
//  NetworkManager.swift
//  NewsApp
//
//  Created by Apple on 23/10/19.
//  Copyright © 2019 abc. All rights reserved.
//

import Foundation
import UIKit
import Alamofire


class NetworkManager {
    

    //---- Get Song List
    class func GetSongList(parameters: [String: Any]?, handler: (APICompletion<SongModel>)? = nil) {
        getRequest(url: Server.shared.apiUrl, parameters: parameters, handler: handler)
    }
    
    class func getRequest<T: Decodable>(url: String?, parameters: [String: Any]? = nil, customeHeaders: [String: Any]? = nil, responseKey: String? = nil, handler: (APICompletion<T>)? = nil) {
        // print(url as Any)
        
        var output: String = ""
        if let param = parameters {
            for (key,value) in param {
                output +=  "\(key)=\(value)&"
            }
        }
        output = String(output.dropLast())
        
        var urlString = url
        if output.count>0 {
            urlString = urlString! + "?\(output)"
        }
        
        request(url: urlString, method: .get, parameters: nil, responseKey: responseKey, customeHeaders: customeHeaders, handler: handler)
    }
    
    
    class func postRequest<T: Decodable>(url: String?, parameters: [String: Any]? = nil, customeHeaders: [String: Any]? = nil, responseKey: String? = nil, handler: (APICompletion<T>)? = nil) {
        // print(url as Any)
        request(url: url, method: .post, parameters: parameters, responseKey: responseKey, customeHeaders: customeHeaders, handler: handler)
    }
    
    class func deleteRequest<T: Decodable>(url: String?, parameters: [String: Any]? = nil, customeHeaders: [String: Any]? = nil, responseKey: String? = nil, handler: (APICompletion<T>)? = nil) {
           // print(url as Any)
           request(url: url, method: .delete, parameters: parameters, responseKey: responseKey, customeHeaders: customeHeaders, handler: handler)
       }
    
    class func patchRequest<T: Decodable>(url: String?, parameters: [String: Any]? = nil, customeHeaders: [String: Any]? = nil, responseKey: String? = nil, handler: (APICompletion<T>)? = nil) {
        // print(url as Any)
        request(url: url, method: .patch, parameters: parameters, responseKey: responseKey, customeHeaders: customeHeaders, handler: handler)
    }
    
    
    
    class func request<T: Decodable>(url: String?, contentType: RequestContentType = .json, method: RequestMethod, parameters: [String: Any]? = nil, responseKey: String? = nil, customeHeaders: [String: Any]? = nil, handler: (APICompletion<T>)? = nil) {
        guard let url = url else {
            handler?(DataResult.failure(APIError.invalidRequest))
            return
        }
        
        let responseKeyvalue = "result"
     
        let params = parameters
        let urlString = url
        
        let resource = APIResource(URLString: urlString, method: method, parameters: params, headers: customeHeaders as? [String : String], contentType: contentType, responseKey: responseKeyvalue)
        return Network(resource: resource).sendRequest(completion: handler)
    }
}
