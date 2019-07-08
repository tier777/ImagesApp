//
//  ImagesListViewController.swift
//  ImagesTest
//
//  Created by Nikita Gorobets on 07/07/2019.
//  Copyright © 2019 ng. All rights reserved.
//

import RxSwift
import RxCocoa

class ImagesListViewController: UIViewController {
    
    private let disposeBag = DisposeBag()
    
    @IBOutlet private weak var tableView: UITableView!
    
    private lazy var viewModel: ImagesListViewModelProtocol = ImagesListViewModel()
}

extension ImagesListViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViews()
    }
}

extension ImagesListViewController {
    
    private func setupViews() {
        
        setupTableView()
    }
    
    private func setupTableView() {
        
        let longTapGesture = UILongPressGestureRecognizer()
        longTapGesture.minimumPressDuration = 1
        longTapGesture.rx.event
            .bind(onNext: {
                [weak self] recognizer in
                
                guard let self = self, recognizer.state == .began else { return }
                
                let point = recognizer.location(in: self.tableView)
                
                if let indexPath = self.tableView.indexPathForRow(at: point) {
                    
                    self.viewModel.deleteResult(at: indexPath.row)
                }
                
            }).disposed(by: disposeBag)
        
        tableView.addGestureRecognizer(longTapGesture)
        
        viewModel.searchResults
            .map { $0.map { ImagesListCellViewModel(searchResult: $0) } }
            .bind(to: tableView.rx.items(cellIdentifier: ImagesListCell.reuseIdentifier, cellType: ImagesListCell.self)) {
                row, cellViewModel, cell in
                
                cell.configure(with: cellViewModel)
            }
            .disposed(by: disposeBag)
    }
}

extension ImagesListViewController {
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if let navigationController = segue.destination as? UINavigationController, let imagesSearchViewController = navigationController.topViewController as? ImagesSearchViewController {
            
            imagesSearchViewController.viewModel.resultForSave
                .distinctUntilChanged()
                .subscribe(onNext: {
                    [weak self] result in
                    
                    guard let self = self, let result = result else { return }
                    
                    self.viewModel.append(searchResult: result)
                    
                }).disposed(by: disposeBag)
        }
    }
}
