//
//  UserCommentReplyCellViewModel.swift
//  SereyIO
//
//  Created by Panha Uy on 4/25/20.
//  Copyright © 2020 Phanha Uy. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift
import RxBinding

class UserCommentReplyCellViewModel: CellViewModel, ShimmeringProtocol {
    
    let data: BehaviorRelay<CommentReplyModel?>
    let isShimmering: BehaviorRelay<Bool>
    
    let profileViewModel: BehaviorSubject<ProfileViewModel?>
    let authorName: BehaviorSubject<String?>
    let publishedAt: BehaviorSubject<String?>
    let titleText: BehaviorSubject<String?>
    let contentAttributedString: BehaviorSubject<NSAttributedString?>
    let sereyValue: BehaviorSubject<String?>
    let upVoteCount: BehaviorSubject<String?>
    let downVoteCount: BehaviorSubject<String?>
    
    init(_ data: CommentReplyModel?) {
        self.data = BehaviorRelay(value: data)
        self.isShimmering = BehaviorRelay(value: false)
        
        self.profileViewModel = BehaviorSubject(value: nil)
        self.authorName = BehaviorSubject(value: nil)
        self.publishedAt = BehaviorSubject(value: nil)
        self.titleText = BehaviorSubject(value: nil)
        self.contentAttributedString = BehaviorSubject(value: nil)
        self.sereyValue = BehaviorSubject(value: nil)
        self.upVoteCount = BehaviorSubject(value: nil)
        self.downVoteCount = BehaviorSubject(value: nil)
        super.init()
        
        setUpRxObservers()
    }
    
    convenience required init(_ isShimmering: Bool = true) {
        self.init(nil)
        
        self.isShimmering.accept(isShimmering)
    }
}

// MARK: - Preparations & Tools
extension UserCommentReplyCellViewModel {
    
    func notifyDataChanged(_ data: CommentReplyModel?) {
        self.profileViewModel.onNext(data?.profileViewModel)
        self.authorName.onNext(data?.author)
        self.publishedAt.onNext(data?.publishedDateString)
        self.titleText.onNext(data?.title)
        self.contentAttributedString.onNext(data?.body.htmlAttributed(size: 10))
        self.sereyValue.onNext(data?.sereyValue)
        self.upVoteCount.onNext("\(data?.votes ?? 0)")
    }
}

//  MARK: - SetUp RxObservers
extension UserCommentReplyCellViewModel {
    
    func setUpRxObservers() {
        setUpContentChangedObservers()
    }
    
    func setUpContentChangedObservers() {
        self.data.asObservable()
            .subscribe(onNext: { [weak self] data in
                self?.notifyDataChanged(data)
            }) ~ self.disposeBag
    }
}
