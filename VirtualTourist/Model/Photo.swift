//
//  Photo.swift
//  VirtualTourist
//
//  Created by Mohamed Ezzat on 10/02/2022.
//

import Foundation

struct _Data:Codable{
    var photos: Photos
}

struct Photos:Codable{
    var photo: [PhotoDetails]
    var pages : Int
}

struct PhotoDetails:Codable{
    var id: String
    var title: String
    var owner: String
    var url_m: String
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        id = try values.decodeIfPresent(String.self, forKey: .id) ?? ""
        title = try values.decodeIfPresent(String.self, forKey: .title) ?? ""
        owner = try values.decodeIfPresent(String.self, forKey: .owner) ?? ""
        url_m = try values.decodeIfPresent(String.self, forKey: .url_m) ?? ""
    }
}
 

