//
//  ImagesSearchViewController.swift
//  ImagesTest
//
//  Created by Nikita Gorobets on 07/07/2019.
//  Copyright © 2019 ng. All rights reserved.
//

import RxSwift
import RxCocoa

class ImagesSearchViewController: UIViewController {
    
    private let disposeBag = DisposeBag()
    
    @IBOutlet private weak var searchBar: UISearchBar!
    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var buttonsContainerBottomConstraint: NSLayoutConstraint!
    @IBOutlet private weak var buttonsContainer: UIView!
    @IBOutlet private weak var closeButton: UIBarButtonItem!
    @IBOutlet private weak var addButton: UIButton!
    @IBOutlet private weak var shuffleButton: UIButton!
    
    private let viewModel: ImagesSearchViewModelProtocol = ImagesSearchViewModel()
    
    private lazy var keyboardOnScreenHeight = Observable.from([
        NotificationCenter.default.rx.notification(UIResponder.keyboardWillShowNotification)
            .map { notification -> CGFloat in
                (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue.height ?? 0
        },
        NotificationCenter.default.rx.notification(UIResponder.keyboardWillHideNotification)
            .map { _ in 0 }
        ])
        .merge()
}

extension ImagesSearchViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViews()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        searchBar.becomeFirstResponder()
    }
}

extension ImagesSearchViewController {
    
    private func setupViews() {
        
        setupCommonViews()
        setupSearchBar()
        setupImageView()
        setupControlButtons()
        setupKeyboard()
    }
    
    private func setupCommonViews() {
        
        closeButton.rx.tap.bind(onNext: {
            [weak self] in
            
            self?.dismiss(animated: true)
            
        }).disposed(by: disposeBag)
        
        let tapGesture = UITapGestureRecognizer()
        view.addGestureRecognizer(tapGesture)
        
        tapGesture.rx.event.bind(onNext: {
            [weak self] recognizer in
            
            self?.view.endEditing(false)
            
        }).disposed(by: disposeBag)
    }
    
    private func setupKeyboard() {
        
        keyboardOnScreenHeight.subscribe(onNext: {
            [weak self] height in
            
            guard let self = self else { return }
            
            UIView.animate(withDuration: 0.3, animations: {
                
                self.buttonsContainerBottomConstraint!.constant = height != 0 ? height - self.view.safeAreaInsets.bottom : height
                
                self.view.layoutIfNeeded()
            })
            
        }).disposed(by: disposeBag)
    }
    
    private func setupControlButtons() {
        
        viewModel.images
            .observeOn(MainScheduler.asyncInstance)
            .map({ $0.count })
            .bind(onNext: {
                [weak self] imagesCount in
                
                self?.addButton.isEnabled = imagesCount > 0
                self?.shuffleButton.isEnabled = imagesCount > 1
                
            }).disposed(by: disposeBag)
        
        shuffleButton.rx.tap.bind(onNext: {
            [weak viewModel] in
            
            viewModel?.shuffle()
            
        }).disposed(by: disposeBag)
    }
    
    private func setupImageView() {
        
        viewModel.currentImage
            .observeOn(MainScheduler.asyncInstance)
            .bind {
                [weak self] image in
                
                self?.imageView.image = image
                
            }.disposed(by: disposeBag)
    }
    
    private func setupSearchBar() {
        
        searchBar.rx.searchButtonClicked.bind(onNext: {
            [weak self] in
            
            self?.view.endEditing(false)
            
        }).disposed(by: disposeBag)
        
        searchBar.rx.text.orEmpty
            .throttle(.milliseconds(500), scheduler: MainScheduler.asyncInstance)
            .distinctUntilChanged()
            .subscribe(onNext: {
                [weak self] q in
                
                self?.viewModel.search(q: q)
                
            }).disposed(by: disposeBag)
    }
}
