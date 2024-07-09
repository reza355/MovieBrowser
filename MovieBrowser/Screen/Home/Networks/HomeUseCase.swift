//
//  HomeUseCase.swift
//  MovieBrowser
//
//  Created by Fathureza Januarza on 09/07/24.
//

import Foundation
import Moya
import RxSwift

protocol HomeUseCaseProtocol {
    func getNowPlayingMovieList(page: Int) -> Observable<[NowPlayingMovieResponse]>
    func searchMovie(keyword: String) -> Observable<[SearchResponse]>
}

final class HomeUseCase: HomeUseCaseProtocol {
    
    let provider = MoyaProvider<HomeMoyaTarget>()
    
    func getNowPlayingMovieList(page: Int) -> Observable<[NowPlayingMovieResponse]> {
        return provider.rx.request(.getNowPlayingMovieList(page: page))
            .asObservable()
            .map([NowPlayingMovieResponse].self, atKeyPath: "results")
    }
    
    func searchMovie(keyword: String) -> Observable<[SearchResponse]> {
        return provider.rx.request(.searchMovie(keyword: keyword))
            .asObservable()
            .map([SearchResponse].self, atKeyPath: "results")
    }
}
