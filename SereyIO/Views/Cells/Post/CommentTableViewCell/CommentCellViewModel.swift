//
//  CommentCellViewModel.swift
//  SereyIO
//
//  Created by Phanha Uy on 3/9/20.
//  Copyright © 2020 Phanha Uy. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift
import RxBinding

class CommentCellViewModel: PostCellViewModel, ShouldReactToAction, PostCellProtocol {
    
    enum Action {
        case upVotePressed
        case downVotePressed
        case replyCommentPressed
    }
    
    lazy var didActionSubject = PublishSubject<CommentCellViewModel.Action>()
    
    let contentAttributedString: BehaviorSubject<NSAttributedString?>
    let conversationText: BehaviorSubject<String?>
    let replies: BehaviorRelay<[PostModel]>
    let isViewConversationHidden: BehaviorSubject<Bool>
    let isReplyHidden: BehaviorRelay<Bool>
    let leadingConstraint: BehaviorRelay<CGFloat>
    let isVoteAllowed: BehaviorSubject<Bool>
    let upVoteEnabled: BehaviorSubject<Bool>
    let flagEnabled: BehaviorSubject<Bool>
    let isVoting: BehaviorSubject<VotedType?>
    
    let shouldReplyComment: PublishSubject<CommentCellViewModel>
    let shouldUpVote: PublishSubject<PostModel>
    let shouldFlag: PublishSubject<PostModel>
    let shouldDownvote: PublishSubject<(VotedType, PostModel)>
    let votedType: BehaviorRelay<VotedType?>
    
    init(_ discussion: PostModel?, canReply: Bool = true, leading: CGFloat = 16) {
        self.contentAttributedString = BehaviorSubject(value: nil)
        self.conversationText = BehaviorSubject(value: nil)
        self.replies = BehaviorRelay(value: discussion?.replies ?? [])
        let isConversationHidden = (discussion?.replies?.isEmpty ?? true) || !canReply
        self.isViewConversationHidden = BehaviorSubject(value: isConversationHidden )
        self.isReplyHidden = BehaviorRelay(value: !canReply)
        self.leadingConstraint = BehaviorRelay(value: leading)
        self.isVoteAllowed = BehaviorSubject(value: false)
        self.votedType = BehaviorRelay(value: nil)
        self.upVoteEnabled = BehaviorSubject(value: true)
        self.flagEnabled = BehaviorSubject(value: true)
        self.isVoting = BehaviorSubject(value: nil)
        
        self.shouldReplyComment = PublishSubject()
        self.shouldUpVote = PublishSubject()
        self.shouldFlag = PublishSubject()
        self.shouldDownvote = PublishSubject()
        super.init(discussion)
        
        setUpRxObservers()
    }
    
    required convenience init(_ isShimmering: Bool) {
        self.init(nil)
        
        self.isShimmering.accept(isShimmering)
    }
    
    override func notifyDataChanged(_ data: PostModel?) {
        super.notifyDataChanged(data)
        
        self.contentAttributedString.onNext(data?.description?.htmlAttributed(size: 12))
        self.conversationText.onNext(String(format: R.string.post.viewConversation.localized(), "(\(data?.answerCount ?? 0))"))
        self.isVoteAllowed.onNext(data?.authorName != AuthData.shared.username)
        self.votedType.accept(data?.votedType)
        self.upVoteEnabled.onNext(data?.votedType != .flag)
        self.flagEnabled.onNext(data?.votedType != .upvote)
    }
}

// MARK: - Action Handlers
fileprivate extension CommentCellViewModel {
    
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
fileprivate extension CommentCellViewModel {
    
    func setUpRxObservers() {
        setUpActionObservers()
    }
    
    func setUpActionObservers() {
        self.didActionSubject.asObservable()
            .subscribe(onNext: { [unowned self] action in
                switch action {
                case .downVotePressed:
                    self.handleFlagPressed()
                case .upVotePressed:
                    self.handleUpVotePressed()
                case .replyCommentPressed:
                    self.shouldReplyComment.onNext(self)
                }
            }) ~ self.disposeBag
    }
}
