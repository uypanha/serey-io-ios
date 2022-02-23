//
//  PostCommentView.swift
//  SereyIO
//
//  Created by Phanha Uy on 3/10/20.
//  Copyright © 2020 Serey IO. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift
import RxBinding
import Rswift

class PostCommentView: NibView {

    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    @IBOutlet weak var voteContainerView: UIStackView!
    @IBOutlet weak var upVoteButton: UIButton!
    @IBOutlet weak var downVoteButton: UIButton!
    @IBOutlet weak var commentTextView: CommentTextView!
    @IBOutlet weak var voterButton: UIButton!
    
    var viewModel: PostCommentViewModel? {
        didSet {
            guard let viewModel = self.viewModel else { return }
            
            self.disposeBag = DisposeBag()
            self.disposeBag ~ [
                viewModel.upVoteCount ~> self.upVoteButton.rx.title(for: .normal),
                viewModel.downVoteCount ~> self.downVoteButton.rx.title(for: .normal),
                viewModel.commentHidden ~> self.commentTextView.rx.isHidden,
                viewModel.votedType
                    .subscribe(onNext: { [weak self] voteType in
                        self?.preparepVoteTypeStyle(voteType)
                    }),
                viewModel.isVoting.asObservable()
                    .subscribe(onNext: { [unowned self] voteType in
                        self.upVoteButton.isHidden = voteType == .upvote ? true : self.upVoteButton.isHidden
                        self.downVoteButton.isHidden = voteType == .flag ? true : self.downVoteButton.isHidden
                        self.loadingIndicator.isHidden = voteType == nil
                        if voteType != nil {
                            self.loadingIndicator.startAnimating()
                        } else {
                            self.upVoteButton.isHidden = false
                            self.downVoteButton.isHidden = false
                        }
                    }),
                viewModel.isVotersHidden ~> self.voterButton.rx.isHidden
            ]
            
            commentTextView.viewModel = viewModel.commentTextViewModel
            setUpRxObservers()
        }
    }
    
    override func xibSetup() {
        super.xibSetup()
        
        self.voterButton.setTitleColor(.gray, for: .normal)
        self.voterButton.setTitleColor(.lightGray, for: .highlighted)
        setUpRxObservers()
    }
}

// MARK: - Preparations
fileprivate extension PostCommentView {
    
    func preparepVoteTypeStyle(_ voteType: VotedType?) {
        let downVoteTintColor: UIColor = voteType == .flag ? .color(.primary) : .gray
        let downVoteIcon: UIImage? = voteType == .flag ? R.image.downVoteFilledIcon() : R.image.downVoteIcon()
        self.downVoteButton.tintColor = downVoteTintColor
        self.downVoteButton.setTitleColor(downVoteTintColor, for: .normal)
        self.downVoteButton.setImage(downVoteIcon, for: .normal)
        
        let upVoteTintColor: UIColor = voteType == .upvote ? .color(.primary) : .gray
        let upVoteIcon: UIImage? = voteType == .upvote ? R.image.upVoteFilledIcon() : R.image.upVoteIcon()
        self.upVoteButton.tintColor = upVoteTintColor
        self.upVoteButton.setTitleColor(upVoteTintColor, for: .normal)
        self.upVoteButton.setImage(upVoteIcon, for: .normal)
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
                self?.viewModel?.didAction(with: .flagPressed)
            }) ~ self.disposeBag
        
        self.voterButton.rx.tap.asObservable()
            .subscribe(onNext: { [weak self] _ in
                self?.viewModel?.didAction(with: .votersPressed)
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
