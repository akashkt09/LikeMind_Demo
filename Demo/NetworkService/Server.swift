//
//  Server.swift
//  NewsApp
//
//  Created by Apple on 22/10/19.
//  Copyright © 2019 abc. All rights reserved.
//

import Foundation
import UIKit
//
enum ServerEnvironment {
    case live, staging, QA
    // Main Server
    var baseURL: String {
        return "http://www.omdbapi.com"
    }
}


let currentEnvironment: ServerEnvironment = .live
//Checkpoint

/// Server base URL string.
public let kBaseURL = currentEnvironment.baseURL

class Server: NSObject, Codable { // checkpoint
    
    
    static let shared = Server()
    
    let apiUrl = "\(currentEnvironment.baseURL)"
    override init() {}
    
    required init(from _: Decoder) throws {}
    
}
