//
//  PostCommentViewModel.swift
//  SereyIO
//
//  Created by Panha Uy on 4/5/20.
//  Copyright © 2020 Phanha Uy. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift
import RxBinding

class PostCommentViewModel: BaseViewModel, ShimmeringProtocol, ShouldReactToAction {
    
    enum Action {
        case upVotePressed
        case downVotePressed
    }
    
    // input:
    lazy var didActionSubject = PublishSubject<Action>()
    
    let post: BehaviorRelay<PostModel?>
    let isShimmering: BehaviorRelay<Bool>
    
    let upVoteCount: BehaviorSubject<String?>
    let downVoteCount: BehaviorSubject<String?>
    let isVoteAllowed: BehaviorSubject<Bool>
    
    let shouldComment: PublishSubject<String>
    let shouldUpVote: PublishSubject<PostModel>
    let shouldDownVote: PublishSubject<PostModel>
    let isUploading: BehaviorSubject<Bool>
    
    let commentTextViewModel: CommentTextViewModel
    
    init(_ postModel: PostModel?) {
        self.post = BehaviorRelay(value: postModel)
        self.isShimmering = BehaviorRelay(value: false)
        self.upVoteCount = BehaviorSubject(value: nil)
        self.downVoteCount = BehaviorSubject(value: nil)
        self.isVoteAllowed = BehaviorSubject(value: true)
        
        self.shouldComment = PublishSubject()
        self.shouldUpVote = PublishSubject()
        self.shouldDownVote = PublishSubject()
        self.isUploading = BehaviorSubject(value: false)
        
        self.commentTextViewModel = CommentTextViewModel()
        super.init()
        
        setUpRxObservers()
    }
    
    required convenience init(_ isShimmering: Bool) {
        self.init(nil)
        
        self.isShimmering.accept(isShimmering)
    }
    
    func updateData(_ data: PostModel) {
        self.post.accept(data)
        self.isShimmering.accept(false)
    }
    
    func clearInput() {
        self.commentTextViewModel.clearInput()
    }
    
    internal func notifyDataChanged(_ data: PostModel?) {
        self.upVoteCount.onNext("\(data?.upvote ?? 0)")
        self.downVoteCount.onNext("\(data?.flag ?? 0)")
        self.isVoteAllowed.onNext(AuthData.shared.username != data?.authorName)
    }
}

// MARK: - SetUp RxObservers
fileprivate extension PostCommentViewModel {
    
    func setUpRxObservers() {
        setUpContentChangedObservers()
        setUpCommentTextViewModel()
        setUpActionObservers()
    }
    
    func setUpContentChangedObservers() {
        self.post.asObservable()
            .subscribe(onNext: { [weak self] discussion in
                self?.notifyDataChanged(discussion)
            }) ~ self.disposeBag
    }
    
    func setUpCommentTextViewModel() {
        self.commentTextViewModel.shouldSendComment
            ~> self.shouldComment
            ~ self.disposeBag
        
        self.isUploading.asObservable()
            ~> self.commentTextViewModel.isUploading
            ~ self.disposeBag
    }
    
    func setUpActionObservers() {
        self.didActionSubject.asObservable()
            .subscribe(onNext: { [weak self] action in
                switch action {
                case .upVotePressed:
                    if let postModel = self?.post.value {
                        self?.shouldUpVote.onNext(postModel)
                    }
                case .downVotePressed:
                    if let postModel = self?.post.value {
                        self?.shouldDownVote.onNext(postModel)
                    }
                }
            }) ~ self.disposeBag
    }
}
