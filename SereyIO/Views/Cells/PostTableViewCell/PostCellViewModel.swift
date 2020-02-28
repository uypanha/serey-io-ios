//
//  PostCellViewModel.swift
//  SereyIO
//
//  Created by Phanha Uy on 2/6/20.
//  Copyright © 2020 Phanha Uy. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift
import RxBinding

class PostCellViewModel: CellViewModel {
    
    let discussion: BehaviorRelay<DiscussionModel?>
    let authorName: BehaviorSubject<String?>
    let publishedAt: BehaviorSubject<String?>
    let thumbnailURL: BehaviorSubject<URL?>
    let tagText: BehaviorSubject<String?>
    let titleText: BehaviorSubject<String?>
    let sereyValue: BehaviorSubject<String?>
    let upVoteCount: BehaviorSubject<String?>
    let downVoteCount: BehaviorSubject<String?>
    let commentCount: BehaviorSubject<String?>
    
    init(_ discussion: DiscussionModel?) {
        self.discussion = BehaviorRelay(value: discussion)
        self.authorName = BehaviorSubject(value: nil)
        self.publishedAt = BehaviorSubject(value: nil)
        self.thumbnailURL = BehaviorSubject(value: nil)
        self.tagText = BehaviorSubject(value: nil)
        self.titleText = BehaviorSubject(value: nil)
        self.sereyValue = BehaviorSubject(value: nil)
        self.upVoteCount = BehaviorSubject(value: nil)
        self.downVoteCount = BehaviorSubject(value: nil)
        self.commentCount = BehaviorSubject(value: nil)
        super.init()
        
        setUpRxObservers()
    }
    
    convenience init(isShimmer: Bool) {
        self.init(nil)
    }
    
    private func notifyDataChanged(_ data: DiscussionModel?) {
        self.authorName.onNext(data?.authorName.capitalized)
        self.publishedAt.onNext(data?.publishedDateString)
        self.thumbnailURL.onNext(data?.firstThumnailURL)
        self.tagText.onNext(data?.categoryItem.first?.capitalized)
        self.titleText.onNext(data?.title)
        self.sereyValue.onNext(data?.sereyValue)
        self.upVoteCount.onNext("\(data?.upvote ?? 0)")
        self.downVoteCount.onNext("\(data?.flag ?? 0)")
        self.commentCount.onNext("\(data?.answerCount ?? 0)")
    }
}

// MARK: - SetUp RxObservers
fileprivate extension PostCellViewModel {
    
    func setUpRxObservers() {
        setUpContentChangedObservers()
    }
    
    func setUpContentChangedObservers() {
        self.discussion.asObservable()
            .subscribe(onNext: { [weak self] discussion in
                self?.notifyDataChanged(discussion)
            }) ~ self.disposeBag
    }
}
