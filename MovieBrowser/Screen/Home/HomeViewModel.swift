//
//  HomeViewModel.swift
//  MovieBrowser
//
//  Created by Fathureza Januarza on 09/07/24.
//

import Foundation
import RxSwift
import RxCocoa

final class HomeViewModel: HomeViewModelProtocol {
    
    private let nowPlayingMovieResponse: BehaviorRelay<[NowPlayingMovieResponse]>
    private let searchResponse: BehaviorRelay<[SearchResponse]>
    
    private let useCase: HomeUseCaseProtocol
    private let disposeBag: DisposeBag
    
    private var currentPage = 1
    private var isLoading = false
    
    init(useCase: HomeUseCaseProtocol = HomeUseCase()) {
        self.useCase = useCase
        
        self.nowPlayingMovieResponse = BehaviorRelay(value: [])
        self.searchResponse = BehaviorRelay(value: [])
        self.disposeBag = DisposeBag()
    }
    
    func fetchNowPlayingMovieList(page: Int) {
        guard !isLoading else { return }
        isLoading = true
        
        useCase.getNowPlayingMovieList(page: page)
            .catch { error in
                self.isLoading = false
                return Observable.error(error)
            }
            .subscribe(onNext: { [weak self] response in
                guard let self = self else { return }
                self.isLoading = false
                var movies = nowPlayingMovieResponse.value
                movies.append(contentsOf: response)
                self.nowPlayingMovieResponse.accept(movies)
            })
            .disposed(by: disposeBag)
    }
    
    func searchMovie(keyword: String) {
        isLoading = true
        useCase.searchMovie(keyword: keyword)
            .catch({ error in
                self.isLoading = false
                return Observable.error(error)
            })
            .subscribe(onNext: { [weak self] response in
                self?.searchResponse.accept(response)
                self?.isLoading = false
            })
            .disposed(by: disposeBag)
    }
    
    func loadNextPage() {
        let nextPage = currentPage + 1
        currentPage = nextPage
        fetchNowPlayingMovieList(page: nextPage)
    }
}

extension HomeViewModel {
    var nowPlayingMovieList: Driver<[NowPlayingMovieResponse]> {
        return nowPlayingMovieResponse
            .asDriver(onErrorDriveWith: .empty())
    }
    
    var searchList: Driver<[SearchResponse]> {
        return searchResponse
            .asDriver(onErrorDriveWith: .empty())
    }
}
