//
//  TrailerModel.swift
//  MovieFlixApp
//
//  Created by iMac on 04/07/21.
//

import Foundation


//MARK:- MovieModel structure
struct TrailerModel: Codable {
    var id: String?
    var iso_639_1: String?
    var iso_3166_1: String?
    var key: String?
    var name: String?
    var site: String?
    var size: Int?
    var type: String?
}
