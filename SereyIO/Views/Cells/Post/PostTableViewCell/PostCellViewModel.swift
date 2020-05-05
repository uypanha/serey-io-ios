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

class PostCellViewModel: CellViewModel, ShimmeringProtocol {
    
    let post: BehaviorRelay<PostModel?>
    let isShimmering: BehaviorRelay<Bool>
    
    let profileViewModel: BehaviorSubject<ProfileViewModel?>
    let authorName: BehaviorSubject<String?>
    let publishedAt: BehaviorSubject<String?>
    let thumbnailURL: BehaviorSubject<URL?>
    let tags: BehaviorSubject<[String]>
    let titleText: BehaviorSubject<String?>
    let contentDesc: BehaviorSubject<String?>
    let sereyValue: BehaviorSubject<String?>
    let upVoteCount: BehaviorSubject<String?>
    let downVoteCount: BehaviorSubject<String?>
    let commentCount: BehaviorSubject<String?>
    let isMoreHidden: BehaviorSubject<Bool>
    
    let shouldShowMoreOption: PublishSubject<PostModel>
    
    init(_ post: PostModel?) {
        self.post = BehaviorRelay(value: post)
        self.profileViewModel = BehaviorSubject(value: nil)
        self.authorName = BehaviorSubject(value: nil)
        self.publishedAt = BehaviorSubject(value: nil)
        self.thumbnailURL = BehaviorSubject(value: nil)
        self.tags = BehaviorSubject(value: [])
        self.titleText = BehaviorSubject(value: nil)
        self.contentDesc = BehaviorSubject(value: nil)
        self.sereyValue = BehaviorSubject(value: nil)
        self.upVoteCount = BehaviorSubject(value: nil)
        self.downVoteCount = BehaviorSubject(value: nil)
        self.commentCount = BehaviorSubject(value: nil)
        self.isShimmering = BehaviorRelay(value: false)
        self.isMoreHidden = BehaviorSubject(value: true)
        
        self.shouldShowMoreOption = PublishSubject()
        super.init()
        
        setUpRxObservers()
    }
    
    required convenience init(_ isShimmering: Bool) {
        self.init(nil)
        
        self.isShimmering.accept(isShimmering)
    }
    
    internal func notifyDataChanged(_ data: PostModel?) {
        self.profileViewModel.onNext(data?.profileViewModel)
        self.authorName.onNext(data?.authorName.capitalized)
        self.publishedAt.onNext(data?.publishedDateString)
        self.thumbnailURL.onNext(data?.firstThumnailURL)
        self.tags.onNext(data?.categoryItem ?? [])
        self.titleText.onNext(data?.title)
        self.contentDesc.onNext(data?.description)
        self.sereyValue.onNext(data?.sereyValue)
        self.upVoteCount.onNext("\(data?.upvote ?? 0)")
        self.downVoteCount.onNext("\(data?.flag ?? 0)")
        self.commentCount.onNext("\(data?.answerCount ?? 0)")
        let isMorePresent = AuthData.shared.isUserLoggedIn ? data?.authorName == AuthData.shared.username : false
        let isOverAWeek = data?.isOverAWeek ?? false
        self.isMoreHidden.onNext(isOverAWeek || !isMorePresent)
    }
    
    func onMoreButtonPressed() {
        if let postModel = self.post.value {
            self.shouldShowMoreOption.onNext(postModel)
        }
    }
}

// MARK: - SetUp RxObservers
private extension PostCellViewModel {
    
    func setUpRxObservers() {
        setUpContentChangedObservers()
    }
    
    func setUpContentChangedObservers() {
        self.post.asObservable()
            .subscribe(onNext: { [weak self] discussion in
                self?.notifyDataChanged(discussion)
            }) ~ self.disposeBag
    }
}
