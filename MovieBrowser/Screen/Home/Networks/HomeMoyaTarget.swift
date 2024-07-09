//
//  HomeMoyaTarget.swift
//  MovieBrowser
//
//  Created by Fathureza Januarza on 09/07/24.
//

import Foundation
import Moya
import RxSwift

internal enum HomeMoyaTarget {
    case getNowPlayingMovieList(page: Int)
    case searchMovie(keyword: String)
}

extension HomeMoyaTarget: TargetType {
    var baseURL: URL {
        let urlBase = "https://api.themoviedb.org/3"
        
        switch self {
        case .getNowPlayingMovieList:
            guard let url = URL(string: "\(urlBase)/movie/now_playing") else {
                return NSURL() as URL
            }
            return url
        case .searchMovie:
            guard let url = URL(string: "\(urlBase)/search/collection") else {
                return NSURL() as URL
            }
            return url
        }
    }
    
    var path: String {
        return ""
    }
    
    var method: Moya.Method {
        return .get
    }
    
    var task: Moya.Task {
        switch self {
        case .getNowPlayingMovieList(let page):
            return .requestParameters(parameters: ["page": page], encoding: URLEncoding.default)
        case .searchMovie(let keyword):
            return .requestParameters(parameters: ["query": keyword, "include_adult": false], encoding: URLEncoding.default)
        }
    }
    
    var headers: [String : String]? {
        guard let bearerToken = bearerToken else {
            return nil
        }
        return [
            "accept": "application/json",
            "Authorization": "Bearer \(bearerToken)"
        ]
    }
    
}

extension HomeMoyaTarget {
    private var bearerToken: String? {
        guard let path = Bundle.main.path(forResource: "Config", ofType: "plist"),
           let config = NSDictionary(contentsOfFile: path) as? [String: Any],
           let bearerToken = config["BearerToken"] as? String else {
            return nil
        }
        
        return bearerToken
    }
}
