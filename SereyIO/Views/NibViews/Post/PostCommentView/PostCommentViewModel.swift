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

class PostCommentViewModel: BaseViewModel, ShimmeringProtocol, PostCellProtocol, ShouldReactToAction {
    
    enum Action {
        case upVotePressed
        case flagPressed
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
    let shouldFlag: PublishSubject<PostModel>
    let shouldDownvote: PublishSubject<(VotedType, PostModel)>
    let votedType: BehaviorRelay<VotedType?>
    let upVoteEnabled: BehaviorSubject<Bool>
    let flagEnabled: BehaviorSubject<Bool>
    let isVoting: BehaviorSubject<VotedType?>
    
    let isUploading: BehaviorSubject<Bool>
    
    let commentTextViewModel: CommentTextViewModel
    
    init(_ postModel: PostModel?) {
        self.post = BehaviorRelay(value: postModel)
        self.isShimmering = BehaviorRelay(value: false)
        self.upVoteCount = BehaviorSubject(value: nil)
        self.downVoteCount = BehaviorSubject(value: nil)
        self.isVoteAllowed = BehaviorSubject(value: true)
        self.votedType = BehaviorRelay(value: nil)
        self.upVoteEnabled = BehaviorSubject(value: true)
        self.flagEnabled = BehaviorSubject(value: true)
        self.isVoting = BehaviorSubject(value: nil)
        
        self.shouldComment = PublishSubject()
        self.shouldUpVote = PublishSubject()
        self.shouldFlag = PublishSubject()
        self.shouldDownvote = PublishSubject()
        
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
        self.votedType.accept(data?.votedType)
        self.upVoteEnabled.onNext(data?.votedType != .flag)
        self.flagEnabled.onNext(data?.votedType != .upvote)
    }
}

// MARK: - Action Handlers
fileprivate extension PostCommentViewModel {
    
    func handleUpVotePressed() {
        if let postModel = self.post.value {
            if let votedType = self.votedType.value {
                self.shouldDownvote.onNext((votedType, postModel))
            } else {
                self.shouldUpVote.onNext(postModel)
            }
        }
    }
    
    func handleFlagPressed() {
        if let postModel = self.post.value {
            if let votedType = self.votedType.value {
                self.shouldDownvote.onNext((votedType, postModel))
            } else {
                self.shouldFlag.onNext(postModel)
            }
        }
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
                    self?.handleUpVotePressed()
                case .flagPressed:
                    self?.handleFlagPressed()
                }
            }) ~ self.disposeBag
    }
}
