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

class CommentCellViewModel: PostCellViewModel, ShouldReactToAction {
    
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
    
    let shouldReplyComment: PublishSubject<CommentCellViewModel>
    let shouldUpVoteComment: PublishSubject<PostModel>
    let shouldFlagComment: PublishSubject<PostModel>
    
    init(_ discussion: PostModel?, canReply: Bool = true, leading: CGFloat = 16) {
        self.contentAttributedString = BehaviorSubject(value: nil)
        self.conversationText = BehaviorSubject(value: nil)
        self.replies = BehaviorRelay(value: discussion?.replies ?? [])
        let isConversationHidden = (discussion?.replies?.isEmpty ?? true) || !canReply
        self.isViewConversationHidden = BehaviorSubject(value: isConversationHidden )
        self.isReplyHidden = BehaviorRelay(value: !canReply)
        self.leadingConstraint = BehaviorRelay(value: leading)
        self.isVoteAllowed = BehaviorSubject(value: false)
        
        self.shouldReplyComment = PublishSubject()
        self.shouldUpVoteComment = PublishSubject()
        self.shouldFlagComment = PublishSubject()
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
        self.conversationText.onNext("View Conversation (\(data?.answerCount ?? 0))")
        self.isVoteAllowed.onNext(data?.authorName != AuthData.shared.username)
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
                    if let postModel = self.discussion.value {
                        self.shouldFlagComment.onNext(postModel)
                    }
                case .upVotePressed:
                    if let postModel = self.discussion.value {
                        self.shouldUpVoteComment.onNext(postModel)
                    }
                case .replyCommentPressed:
                    self.shouldReplyComment.onNext(self)
                }
            }) ~ self.disposeBag
    }
}
