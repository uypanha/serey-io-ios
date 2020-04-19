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

    @IBOutlet weak var voteContainerView: UIStackView!
    @IBOutlet weak var upVoteButton: UIButton!
    @IBOutlet weak var downVoteButton: UIButton!
    @IBOutlet weak var commentTextView: CommentTextView!
    
    var viewModel: PostCommentViewModel? {
        didSet {
            guard let viewModel = self.viewModel else { return }
            
            self.disposeBag = DisposeBag()
            self.disposeBag ~ [
                viewModel.upVoteCount ~> self.upVoteButton.rx.title(for: .normal),
                viewModel.downVoteCount ~> self.downVoteButton.rx.title(for: .normal),
                viewModel.isVoteAllowed.map { !$0 } ~> self.voteContainerView.rx.isHidden
            ]
            
            commentTextView.viewModel = viewModel.commentTextViewModel
            setUpRxObservers()
        }
    }
    
    override func xibSetup() {
        super.xibSetup()
        
        setUpRxObservers()
    }
}

// MARK: - SetUp RxObservers
fileprivate extension PostCommentView {
    
    func setUpRxObservers() {
        setUpControlObsservers()
    }
    
    func setUpControlObsservers() {
        
        self.upVoteButton.rx.tap.asObservable()
            .subscribe(onNext: { [weak self] _ in
                self?.viewModel?.didAction(with: .upVotePressed)
            }) ~ self.disposeBag
        
        self.downVoteButton.rx.tap.asObservable()
            .subscribe(onNext: { [weak self] _ in
                self?.viewModel?.didAction(with: .downVotePressed)
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
