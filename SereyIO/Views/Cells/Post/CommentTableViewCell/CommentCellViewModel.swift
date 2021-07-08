//
//  CommentCellViewModel.swift
//  SereyIO
//
//  Created by Phanha Uy on 3/9/20.
//  Copyright © 2020 Serey IO. All rights reserved.
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
    let shouldReplyComment: PublishSubject<CommentCellViewModel>
    
    init(_ discussion: PostModel?, canReply: Bool = true, leading: CGFloat = 16) {
        self.contentAttributedString = BehaviorSubject(value: nil)
        self.conversationText = BehaviorSubject(value: nil)
        self.replies = BehaviorRelay(value: discussion?.replies ?? [])
        let isConversationHidden = (discussion?.replies?.isEmpty ?? true) || !canReply
        self.isViewConversationHidden = BehaviorSubject(value: isConversationHidden )
        self.isReplyHidden = BehaviorRelay(value: !canReply)
        self.leadingConstraint = BehaviorRelay(value: leading)
        
        self.shouldReplyComment = PublishSubject()
        super.init(discussion)
        
        setUpRxObservers()
    }
    
    required convenience init(_ isShimmering: Bool) {
        self.init(nil)
        
        self.isShimmering.accept(isShimmering)
    }
    
    override func notifyDataChanged(_ data: PostModel?) {
        super.notifyDataChanged(data)
        
        self.contentAttributedString.onNext(data?.descriptionText?.htmlAttributed(size: 12))
        self.conversationText.onNext(String(format: R.string.post.viewConversation.localized(), "\(data?.answerCount ?? 0)"))
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
