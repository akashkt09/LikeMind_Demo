//
//  SongModel.swift
//  Demo
//
//  Created by Akash on 09/04/21.
//

import Foundation


struct SongModel: Codable{
    var search: [SongList]
    var response: String?
    var error: String?
    enum CodingKeys: String, CodingKey {
        case search = "Search"
        case response = "Response"
        case error = "Error"
    }
}


struct SongList: Codable{
    var title, poster, year, imdbId, type: String?

    enum CodingKeys: String, CodingKey{
        case title = "Title"
        case poster = "Poster"
        case year = "Year"
        case type = "Type"
        case imdbId
    }
}
