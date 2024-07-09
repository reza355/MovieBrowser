//
//  HomeViewController.swift
//  MovieBrowser
//
//  Created by Fathureza Januarza on 09/07/24.
//

import UIKit
import RxSwift
import RxCocoa

final class HomeViewController: UIViewController {
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Find Now Playing Movies"
        label.font = .systemFont(ofSize: 24, weight: .semibold)
        label.textColor = .black
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var inputTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Search Movie"
        textField.borderStyle = .roundedRect
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .white
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(MoviePosterCell.self, forCellWithReuseIdentifier: "MoviePosterCell")
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        return collectionView
    }()
    
    private var viewModel: HomeViewModelProtocol?
    private var nowPlayingMovieList: [NowPlayingMovieResponse] = []
    private var searchList: [SearchResponse] = []
    private var disposeBag = DisposeBag()
    
    init(viewModel: HomeViewModelProtocol) {
        super.init(nibName: nil, bundle: nil)
        self.viewModel = viewModel
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        setupView()
        bindViewModel()
    }
    
    private func setupView() {
        view.addSubview(titleLabel)
        view.addSubview(inputTextField)
        view.addSubview(collectionView)
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            inputTextField.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 16),
            inputTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            inputTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            collectionView.topAnchor.constraint(equalTo: inputTextField.bottomAnchor, constant: 16),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    private func bindViewModel() {
        guard let viewModel = viewModel else {
            return
        }
        
        viewModel.fetchNowPlayingMovieList(page: 1)
        
        viewModel.nowPlayingMovieList
            .drive(onNext: { [weak self] movies in
                self?.nowPlayingMovieList = movies
                self?.collectionView.reloadData()
            }).disposed(by: disposeBag)
        
        viewModel.searchList
            .drive(onNext: { [weak self] movies in
                self?.searchList = movies
                self?.collectionView.reloadData()
            }).disposed(by: disposeBag)
        
        inputTextField.rx.text.asDriver()
            .throttle(.milliseconds(100))
            .drive { [weak self] searchText in
                if let text = searchText {
                    self?.viewModel?.searchMovie(keyword: text)
                } else {
                    self?.viewModel?.fetchNowPlayingMovieList(page: 1)
                }
            }
            .disposed(by: disposeBag)
    }
}

extension HomeViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return nowPlayingMovieList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MoviePosterCell", for: indexPath) as? MoviePosterCell else {
            return UICollectionViewCell()
        }
        
        if inputTextField.text?.isEmpty == false, searchList.count > 0 {
            let search = searchList[indexPath.row]
            cell.configure(with: search)
        } else if nowPlayingMovieList.count > 0 {
            let movie = nowPlayingMovieList[indexPath.row]
            cell.configure(with: movie)
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (collectionView.frame.width - 32) / 2
        return CGSize(width: width, height: width * 1.5)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        let height = scrollView.frame.size.height
        
        if offsetY > contentHeight - height * 1.5 {
            viewModel?.loadNextPage()
        }
    }
}
