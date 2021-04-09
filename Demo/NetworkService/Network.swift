//
//  Network.swift
//  NewsApp
//
//  Created by Apple on 23/10/19.
//  Copyright © 2019 abc. All rights reserved.
//

import Foundation
import UIKit

import Alamofire

typealias CODE = Int

extension Dictionary {
    func percentEscaped() -> String {
        return map { (key, value) in
            let escapedKey = "\(key)".addingPercentEncoding(withAllowedCharacters: .urlQueryValueAllowed) ?? ""
            let escapedValue = "\(value)".addingPercentEncoding(withAllowedCharacters: .urlQueryValueAllowed) ?? ""
            return escapedKey + "=" + escapedValue
        }
        .joined(separator: "&")
    }
}

extension CharacterSet {
    static let urlQueryValueAllowed: CharacterSet = {
        let generalDelimitersToEncode = ":#[]@" // does not include "?" or "/" due to RFC 3986 - Section 3.4
        let subDelimitersToEncode = "!$&'()*+,;="
        
        var allowed = CharacterSet.urlQueryAllowed
        allowed.remove(charactersIn: "\(generalDelimitersToEncode)\(subDelimitersToEncode)")
        return allowed
    }()
}

extension Dictionary {
    var jsonStringRepresentation: String? {
        guard let theJSONData = try? JSONSerialization.data(withJSONObject: self,
                                                            options: [.prettyPrinted]) else {
                                                                return nil
        }
        
        return String(data: theJSONData, encoding: .ascii)
    }
}

class Network {
    let apiResource: APIResource!
    let decoder = JSONDecoder()
    
//
    static var alamoFireManager : Session = {

        let configuration = URLSessionConfiguration.default
        configuration.urlCache = nil //---- added code by
        configuration.timeoutIntervalForRequest = 120
        configuration.timeoutIntervalForResource = 120
        let alamoFireManager = Alamofire.Session(configuration: configuration)
        return alamoFireManager
    }()
    

    
    init(resource: APIResource?) {
        self.apiResource = resource
    }
    
    func sendRequest<T: Decodable>(completion: APICompletion<T>?) //-> DataRequestID
    {
        guard let url = URL(string: apiResource.urlString) else {
            return
        }
        var request = URLRequest(url: url)
                
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        if let parameters = apiResource.customHeader {
            var headerData :Data
            do {
                headerData = try JSONSerialization.data(withJSONObject: parameters, options: .prettyPrinted)
                // here "jsonData" is the dictionary encoded in JSON data
                
                let decoded = try JSONSerialization.jsonObject(with: headerData, options: [])
                // here "decoded" is of type `Any`, decoded from JSON data
                
                // you can now cast it with the right type
                if let dictFromJSON = decoded as? [String:String] {
                    print(dictFromJSON)
                    
                    for (key, value) in dictFromJSON {
                        request.setValue(value, forHTTPHeaderField: key)
                    }
                }
                
            } catch {
                print(error.localizedDescription)
            }
        }
        request.httpMethod = self.apiResource.method.rawValue
        
        if let parameters = apiResource.parameter {
            var jsonData :Data
            do {
                jsonData = try JSONSerialization.data(withJSONObject: parameters, options: .prettyPrinted)
                // here "jsonData" is the dictionary encoded in JSON data
                
                let decoded = try JSONSerialization.jsonObject(with: jsonData, options: [])
                // here "decoded" is of type `Any`, decoded from JSON data
                
                // you can now cast it with the right type
                if let dictFromJSON = decoded as? [String:String] {
                    print("it is dictFromJSON ---%@",dictFromJSON)
                }
                
                request.httpBody = jsonData
            } catch {
                print(error.localizedDescription)
            }
        }
        Network.alamoFireManager.request(request)
            .responseJSON { responseData in
                let result: DataResult<T>
                do {
                    let APIResponse: APIResponse<T> = try self.parseJSON(data: responseData.data, error: responseData.error, responseData: responseData.response, statuscode: responseData.response?.statusCode ?? 200)
                    
                    switch responseData.result{
                        case .success(_):
                    
                            result = DataResult.success(APIResponse)
                            completion?(result)
                            break
                        
                        case .failure(let error):
                            print("Request failed with error: \(error)")
                            Loader.hideLoader()
                    }
                }
                catch {
                    let error = error as? APIError ?? APIError.somethingWentWrong
                    completion?(DataResult.failure(error ))
                }
        }
        
    }

    
    func validate(data: Data?, error: Error?, responseData: URLResponse? = nil) -> (success: Bool, error: APIError?) {
        /// Here just basic validation checking data is nil or not and error is present.
        var validationError: APIError?
        if error != nil
        {
            var errorMessage: String?
            var code = (error as NSError?)?.code
            do {
                if let jsonData = data {
                    if let jsonResult = try JSONSerialization.jsonObject(with: jsonData, options: .mutableContainers) as? [String: Any] {
                        errorMessage = jsonResult["message"] as? String
                        if let c = jsonResult["code"] as? Int {
                            code = c
                        }
                        print(jsonResult)
                    }
                    
                }
                } catch {}
                let msg = errorMessage ?? (error as NSError?)?.localizedDescription
                if code == 403 {
                    validationError = APIError.accountBlocked(message: msg)
                } else if code == APIStatusCode.invalidAccessToken.rawValue {
                    validationError = APIError.invalidAccessToken
                } else {
                    validationError = APIError.generalError(code: code, message: msg)
                }
                let status = (validationError == nil) ? true : false
                return (status, validationError)
            
        }
        if data == nil {
            
            validationError = APIError.invalidResponse
        }
        let status = (validationError == nil) ? true : false
        return (status, validationError)
    }
    
    func parseJSON<T: Decodable>(data: Data?, error: Error?, responseData: URLResponse? = nil,statuscode:Int) throws -> APIResponse<T> {
        var parsedModel: APIResponse<T>
        
        let validation = self.validate(data: data, error: error, responseData: responseData)
        guard validation.success, validation.error == nil else {
            throw validation.error!
        }
        
        var statusCode = NSNotFound
        let projson = try JSONSerialization.jsonObject(with: data!, options: [])
        //print("json is --%@",projson)
        
    
        let dic = projson as? [String:Any]
        
        let dicstatusCode = dic? ["status_code"] as? Int
        
        statusCode = statuscode
        
        var message = ""
        var responseValueStatus = false
        
        if nil != projson as? JSONDictionary
        {
            
            if let mes = (projson as AnyObject).value(forKeyPath: "message") as? String {
                message = mes
            }
            if let responseStatus = (projson as AnyObject).value(forKeyPath: "status") as? Bool
            {
                responseValueStatus = responseStatus
            }
            
            
            
        }
        guard type(of: projson) != NSNull.self else {
            //return (nil, validation.error)
            
            throw APIError.parsingError
        }
        
        //        let headers = responseData.
        
        if T.self == CODE.self
        {
            
            ///If API is requested just to return status code. we don't do decoding.
            parsedModel = APIResponse<T>(statusCode: statusCode, data: nil, status: responseValueStatus, message: message)
        }
            
        else {
            var obj: T?, parseError: APIError?
            do {
                let decoder = JSONDecoder()
                obj = try decoder.decode(T.self, from: data!)
            }
                
            catch let error {
                
                print(error)
                ///Some decoding error occured.
                parseError = APIError.parsingError
            }
            
            ///Some API returns just status code in some scenarios.
            ///to handle that we check for parsed object and status code.
            if obj == nil, statusCode != NSNotFound
            {
                ///If object is nil and contain valid status code. then we need to pass success response in completion.
                parsedModel = APIResponse<T>(statusCode: statusCode, data: nil, status: responseValueStatus, message: message)
            }
            else if let model = obj
            {
                parsedModel = APIResponse<T>(statusCode: statusCode, data: model, status: responseValueStatus, message: message)
            } else {
                //throwing parse error
                throw parseError ?? APIError.parsingError
            }
        }
        return parsedModel
    }
    
}
