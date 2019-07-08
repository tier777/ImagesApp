//
//  ImagesListCell.swift
//  ImagesTest
//
//  Created by Nikita Gorobets on 08/07/2019.
//  Copyright © 2019 ng. All rights reserved.
//

import RxSwift
import RxCocoa

class ImagesListCell: UITableViewCell {
    
    static let reuseIdentifier = "ImagesListCell"
    
    private let disposeBag = DisposeBag()
    
    @IBOutlet private weak var searchImageView: UIImageView!
    @IBOutlet private weak var urlLabel: UILabel!
    
    private var viewModel: ImagesListCellViewModel?
    
    func configure(with viewModel: ImagesListCellViewModel) {
        
        self.viewModel = viewModel
        
        viewModel.url.subscribe(onNext: {
            [weak self] url in
            
            self?.urlLabel.text = url
            
        }).disposed(by: disposeBag)
        
        viewModel.imageData.subscribe(onNext: {
            [weak self] data in
            
            self?.searchImageView.image = data != nil ? UIImage(data: data!) : nil
            
        }).disposed(by: disposeBag)
    }
}
