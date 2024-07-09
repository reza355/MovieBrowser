//
//  SearchResponse.swift
//  MovieBrowser
//
//  Created by Fathureza Januarza on 09/07/24.
//

import Foundation

struct SearchResponse: Codable {
    let adult: Bool
    let backdropPath: String
    let id: Int
    let name, originalLanguage, originalName, overview: String
    let posterPath: String

    enum CodingKeys: String, CodingKey {
        case adult
        case backdropPath = "backdrop_path"
        case id, name
        case originalLanguage = "original_language"
        case originalName = "original_name"
        case overview
        case posterPath = "poster_path"
    }
}
