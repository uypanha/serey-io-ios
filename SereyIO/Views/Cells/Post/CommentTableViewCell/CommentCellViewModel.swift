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

class CommentCellViewModel: PostCellViewModel {
    
    let contentAttributedString: BehaviorSubject<NSAttributedString?>
    let conversationText: BehaviorSubject<String?>
    let replies: BehaviorRelay<[PostModel]>
    let isReplyButtonHidden: BehaviorSubject<Bool>
    
    override init(_ discussion: PostModel?) {
        self.contentAttributedString = BehaviorSubject(value: nil)
        self.conversationText = BehaviorSubject(value: nil)
        self.replies = BehaviorRelay(value: discussion?.replies ?? [])
        self.isReplyButtonHidden = BehaviorSubject(value: true)
        super.init(discussion)
        
        self.replies.asObservable()
            .map { $0.isEmpty }
            ~> self.isReplyButtonHidden
            ~ self.disposeBag
    }
    
    override func notifyDataChanged(_ data: PostModel?) {
        super.notifyDataChanged(data)
        
        self.contentAttributedString.onNext(data?.description?.htmlAttributed(size: 12))
        self.conversationText.onNext("View Conversation (\(data?.answerCount ?? 0))")
    }
}
