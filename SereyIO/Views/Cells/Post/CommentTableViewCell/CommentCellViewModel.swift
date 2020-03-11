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
    
    let replies: BehaviorRelay<[PostModel]>
    let isReplyButtonHidden: BehaviorSubject<Bool>
    
    override init(_ discussion: PostModel?) {
        self.replies = BehaviorRelay(value: discussion?.replies ?? [])
        self.isReplyButtonHidden = BehaviorSubject(value: true)
        super.init(discussion)
        
        self.replies.asObservable()
            .map { $0.isEmpty }
            ~> self.isReplyButtonHidden
            ~ self.disposeBag
    }
}
