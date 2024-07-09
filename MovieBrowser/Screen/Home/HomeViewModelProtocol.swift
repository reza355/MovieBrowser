//
//  HomeViewModelProtocol.swift
//  MovieBrowser
//
//  Created by Fathureza Januarza on 09/07/24.
//

import Foundation
import RxCocoa
import RxSwift

protocol HomeViewModelProtocol {
    // - MARK: Input
    func fetchNowPlayingMovieList(page: Int)
    func searchMovie(keyword: String)
    func loadNextPage()
    
    // - MARK: Output
    var nowPlayingMovieList: Driver<[NowPlayingMovieResponse]> { get }
    var searchList: Driver<[SearchResponse]> { get }
}
