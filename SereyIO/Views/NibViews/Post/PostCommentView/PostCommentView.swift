//
//  PostCommentView.swift
//  SereyIO
//
//  Created by Phanha Uy on 3/10/20.
//  Copyright © 2020 Phanha Uy. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift
import RxBinding

class PostCommentView: NibView {

    @IBOutlet weak var upVoteButton: UIButton!
    @IBOutlet weak var downVoteButton: UIButton!
    @IBOutlet weak var profileView: ProfileView!
    @IBOutlet weak var commentTextField: UITextField!
    @IBOutlet weak var sendButton: UIButton!
    
    var viewModel: PostCommentViewModel? {
        didSet {
            guard let viewModel = self.viewModel else { return }
            
            self.disposeBag = DisposeBag()
            self.disposeBag ~ [
                viewModel.profileViewModel ~> self.profileView.rx.profileViewModel,
                viewModel.upVoteCount ~> self.upVoteButton.rx.title(for: .normal),
                viewModel.downVoteCount ~> self.downVoteButton.rx.title(for: .normal)
            ]
            
            viewModel.commentTextFieldViewModel.dispose()
            viewModel.commentTextFieldViewModel.bind(with: self.commentTextField)
            viewModel.commentTextFieldViewModel.textFieldText.asObservable()
                .map { $0 != nil && !$0!.isEmpty }
                ~> self.sendButton.rx.isEnabled
                ~ self.disposeBag
            
            setUpRxObservers()
        }
    }
    
    override func xibSetup() {
        super.xibSetup()
        
        self.sendButton.isHidden = true
        self.sendButton.isEnabled = false
        self.sendButton.setImage(R.image.sendIcon()?.image(withTintColor: .lightGray), for: .disabled)
        self.sendButton.setImage(R.image.sendIcon()?.image(withTintColor: ColorName.primary.color), for: .normal)
        setUpRxObservers()
    }
}

// MARK: - SetUp RxObservers
fileprivate extension PostCommentView {
    
    func setUpRxObservers() {
        setUpControlObsservers()
    }
    
    func setUpControlObsservers() {
        self.commentTextField.rx.controlEvent(.editingDidBegin)
            .map { _ in false }
            ~> self.sendButton.rx.isHidden
            ~ self.disposeBag
        
        self.commentTextField.rx.controlEvent(.editingDidEnd)
            .map { _ in true }
            ~> self.sendButton.rx.isHidden
            ~ self.disposeBag
        
        self.upVoteButton.rx.tap.asObservable()
            .subscribe(onNext: { [weak self] _ in
                self?.viewModel?.didAction(with: .upVotePressed)
            }) ~ self.disposeBag
        
        self.downVoteButton.rx.tap.asObservable()
            .subscribe(onNext: { [weak self] _ in
                self?.viewModel?.didAction(with: .downVotePressed)
            }) ~ self.disposeBag
        
        self.sendButton.rx.tap.asObservable()
            .subscribe(onNext: { [weak self] _ in
                self?.viewModel?.didAction(with: .sendCommentPressed)
            }) ~ self.disposeBag
    }
}

#if os(iOS) || os(tvOS)

import RxSwift
import UIKit

extension Reactive where Base: PostCommentView {
    
    /// Bindable sink for `profileViewModel` property.
    internal var viewModel: Binder<PostCommentViewModel?> {
        return Binder(self.base) { postCommentView, model in
            postCommentView.viewModel = model
        }
    }
}

#endif
