//
//  NetworkConstants.swift
//  ThatsGams
//
//  Created by Admin on 18/12/19.
//  Copyright © 2019 App Studio. All rights reserved.
//

import Foundation

public enum RequestMethod: String {
    case head = "HEAD"
    case post = "POST"
    case put = "PUT"
    case get = "GET"
    case delete = "DELETE"
    case patch = "PATCH"
}

public enum RequestContentType {
    case json
    case urlEncoded
    case multipart
}

struct APIResource {
    /// Full URL string
    let urlString: String
    let method: RequestMethod
    let contentType: RequestContentType
    let parameter: [String: Any]?
    let customHeader: [String: String]?
    /// By default for every API response json will be parsed from root level. If we need to parse response from any child items we can specify here.
    let responseKeyPath: String?
    
    let uploadData: UploadData?
   
//    let formData: FormData?
//    /// If session gets expired, it will be handled in base level. If we require it in completion block, set this flag. Currently being used for touch/face ID login.
//    var shouldReturnSessionExpiry: Bool = false
    
    /**
     API Resource constructor.
     - parameter url: Complete URL string.
     - parameter method: request method of type RequestMethod. By default method will be .get
     - parameter parameters: request parameters. For get method this be passes as URL parameters, for post & put this will be passed as body paramaters. Default is nil.
     - parameter headers: Any specific headers required for the API. **No need to pass common headers.**.
     - parameter contentType: content type of type RequestContentType. This value will be set for the header field **Content-Type**. Default value is .urlEncoded
     - parameter formData: body parameters for multipart request.
     - parameter responseKey: Key path in the response json to be considered for parsing. By default response json will be parsed from root level.
     
     */
    init(URLString url: String, method: RequestMethod = .get,
         parameters: [String: Any]? = nil, headers: [String: String]? = nil,
         contentType: RequestContentType = .urlEncoded, responseKey: String? = nil, upload: UploadData? = nil) {
        self.urlString = url
        self.method = method
        self.contentType = contentType
        self.parameter = parameters
        self.customHeader = headers
        self.responseKeyPath = responseKey
        self.uploadData = upload
        
    }
    
    func initRequest(URLString url: String, method: RequestMethod = .get,
          parameters: [String: Any]? = nil, headers: [String: String]? = nil,
          contentType: RequestContentType = .urlEncoded, responseKey: String? = nil, upload: UploadData? = nil)
        {
         
        }

}

public typealias JSONDictionary = [String: Any]

public struct APIResponse<Value> {
    let statusCode: Int?
    let data: Value?
    let message: String?
    let status:Bool?
    let responseHeaders: [AnyHashable: Any]?
    
    init(statusCode: Int?, data: Value?, responseHeaders: [AnyHashable: Any]? = nil,status:Bool?, message: String?) {
        self.statusCode = statusCode
        self.data = data
        self.responseHeaders = responseHeaders
        self.message = message
        self.status = status
        
    }
}


public struct UploadData {
    let fileName: String
    let fileType: String
    let data: Data
    let fileDic: [String:Any]
    let videodata: [Data]
    
    init(filename: String, filetype: String, data: Data,fileDic: [String:Any], videodata: [Data]) {
        self.fileName = filename
        self.fileType = filetype
        self.data = data
        self.fileDic = fileDic
        self.videodata = videodata
    }
}



public enum APIError: Error {
    case noInternetConnection
    case invalidAccessToken
    case sessionExpired
    case invalidRequest
    case invalidResponse
    case parsingError
    case somethingWentWrong
    case needRetry
    case generalError(code: Int?, message: String?)
    case accountBlocked(message:String?)
    
    func localizedDescription() -> String {
        switch self {
        case .noInternetConnection:
            return "No Internet Connection"
        case .invalidRequest:
            return "Problem with network request. please try later"
        case .parsingError:
            return "Unable to parse the server response. please try later"
        case .somethingWentWrong:
            return "Something went wrong. please try later"
        case .generalError(_, let message):
            return message ?? "Something went wrong. please try later"
        case .accountBlocked(let message):
            return message ?? "Something went wrong. please try later"
        default:
            return "Something went wrong. please try later"
        }
    }
    
    func localizedCode() -> Int {
        switch self {
        case .noInternetConnection:
            return 0
        case .invalidRequest:
            return 0
        case .parsingError:
            return 0
        case .somethingWentWrong:
            return 0
        case .generalError(let code, _):
            return code ?? 0
        case .accountBlocked( _):
            return 0
        default:
            return 0
        }
    }
    
}

public enum DataResult<D> {
    case success(APIResponse<D>)
    case failure(APIError)
    
    /// Gives the response if result is success. else returns nil
    public var response: APIResponse<D>? {
        switch self {
        case .success(let value):
            return value
        case .failure:
            return nil
        }
    }
}

enum APIStatusCode: Int {
    case success = 200
    case invalidRequest = 501
    case invalidAccessToken = 401
    case sessionExpired = 3462
}

public typealias APICompletion<D: Decodable> = ((DataResult<D>) -> (Void))

