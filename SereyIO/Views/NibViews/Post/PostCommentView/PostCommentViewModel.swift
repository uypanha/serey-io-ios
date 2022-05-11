//
//  PostCommentViewModel.swift
//  SereyIO
//
//  Created by Panha Uy on 4/5/20.
//  Copyright © 2020 Serey IO. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift
import RxBinding

class PostCommentViewModel: BaseViewModel, ShimmeringProtocol, PostCellProtocol, ShouldReactToAction {
    
    enum Action {
        case upVotePressed
        case flagPressed
        case votersPressed
        case sharePressed
    }
    
    // input:
    lazy var didActionSubject = PublishSubject<Action>()
    
    let post: BehaviorRelay<PostModel?>
    let isShimmering: BehaviorRelay<Bool>
    
    let upVoteCount: BehaviorSubject<String?>
    let downVoteCount: BehaviorSubject<String?>
    let isVoteAllowed: BehaviorRelay<Bool>
    
    let shouldComment: PublishSubject<String>
    let shouldUpVote: PublishSubject<PostModel>
    let shouldFlag: PublishSubject<PostModel>
    let shouldDownvote: PublishSubject<(VotedType, PostModel)>
    let shouldShowVoters: PublishSubject<Void>
    let shouldShare: PublishSubject<Void>
    
    let votedType: BehaviorRelay<VotedType?>
    let upVoteEnabled: BehaviorSubject<Bool>
    let flagEnabled: BehaviorSubject<Bool>
    let isVoting: BehaviorSubject<VotedType?>
    let commentHidden: BehaviorSubject<Bool>
    let isVotersHidden: BehaviorSubject<Bool>
    let isUploading: BehaviorSubject<Bool>
    
    let commentTextViewModel: CommentTextViewModel
    
    init(_ postModel: PostModel?) {
        self.post = .init(value: postModel)
        self.isShimmering = .init(value: false)
        self.upVoteCount = .init(value: nil)
        self.downVoteCount = .init(value: nil)
        self.isVoteAllowed = .init(value: true)
        self.votedType = .init(value: nil)
        self.upVoteEnabled = .init(value: true)
        self.flagEnabled = .init(value: true)
        self.isVoting = .init(value: nil)
        self.commentHidden = .init(value: false)
        self.isVotersHidden = .init(value: true)
        
        self.shouldComment = .init()
        self.shouldUpVote = .init()
        self.shouldFlag = .init()
        self.shouldDownvote = .init()
        self.shouldShowVoters = .init()
        self.shouldShare = .init()
        
        self.isUploading = .init(value: false)
        
        self.commentTextViewModel = .init()
        super.init()
        
        setUpRxObservers()
        registerForNotifs()
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
        self.upVoteCount.onNext("\(data?.voterCount ?? 0)")
        self.downVoteCount.onNext("\(data?.flaggerCount ?? 0)")
        self.isVoteAllowed.accept(AuthData.shared.username != data?.author)
        self.votedType.accept(data?.votedType)
        self.upVoteEnabled.onNext(data?.votedType != .flag)
        self.flagEnabled.onNext(data?.votedType != .upvote)
        self.isVotersHidden.onNext((data?.voterCount ?? 0) == 0)
        self.commentHidden.onNext(!AuthData.shared.isUserLoggedIn)
    }
    
    deinit {
        unregisterFromNotifs()
    }
}

// MARK: - Action Handlers
fileprivate extension PostCommentViewModel {
    
    func handleUpVotePressed() {
        if let postModel = self.post.value, self.isVoteAllowed.value {
            if let votedType = self.votedType.value {
                self.shouldDownvote.onNext((votedType, postModel))
            } else {
                self.shouldUpVote.onNext(postModel)
            }
        }
    }
    
    func handleFlagPressed() {
        if let postModel = self.post.value, self.isVoteAllowed.value {
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
                case .votersPressed:
                    self?.shouldShowVoters.onNext(())
                case .sharePressed:
                    self?.shouldShare.onNext(())
                }
            }) ~ self.disposeBag
    }
}

// MARK: - NotificationObserver
extension PostCommentViewModel: NotificationObserver {
    
    func notificationReceived(_ notification: Notification) {
        guard let appNotif = notification.appNotification else { return }
        switch appNotif {
        case .userDidLogin, .userDidLogOut:
            self.commentHidden.onNext(!AuthData.shared.isUserLoggedIn)
        default:
            break
        }
    }
}

