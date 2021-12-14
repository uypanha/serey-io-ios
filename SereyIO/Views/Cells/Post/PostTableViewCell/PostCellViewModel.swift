//
//  PostCellViewModel.swift
//  SereyIO
//
//  Created by Phanha Uy on 2/6/20.
//  Copyright © 2020 Serey IO. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift
import RxBinding

class PostCellViewModel: CellViewModel, ShimmeringProtocol, PostCellProtocol {
    
    let post: BehaviorRelay<PostModel?>
    let isShimmering: BehaviorRelay<Bool>
    
    let loggedUserInfo: BehaviorRelay<UserModel?>
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
    
    let isVoteAllowed: BehaviorRelay<Bool>
    let upVoteEnabled: BehaviorSubject<Bool>
    let flagEnabled: BehaviorSubject<Bool>
    let isVoting: BehaviorSubject<VotedType?>
    
    let shouldShowMoreOption: PublishSubject<PostModel>
    let shouldShowPostsByCategory: PublishSubject<PostModel>
    let shouldShowAuthorProfile: PublishSubject<PostModel>
    
    let shouldUpVote: PublishSubject<PostModel>
    let shouldFlag: PublishSubject<PostModel>
    let shouldDownvote: PublishSubject<(VotedType, PostModel)>
    let votedType: BehaviorRelay<VotedType?>
    
    init(_ post: PostModel?) {
        self.loggedUserInfo = .init(value: AuthData.shared.loggedUserModel)
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
        
        self.isVoteAllowed = BehaviorRelay(value: false)
        self.upVoteEnabled = BehaviorSubject(value: true)
        self.flagEnabled = BehaviorSubject(value: true)
        self.isVoting = BehaviorSubject(value: nil)
        
        self.shouldShowMoreOption = PublishSubject()
        self.shouldShowPostsByCategory = PublishSubject()
        self.shouldShowAuthorProfile = PublishSubject()
        
        self.shouldUpVote = PublishSubject()
        self.shouldFlag = PublishSubject()
        self.shouldDownvote = PublishSubject()
        self.votedType = BehaviorRelay(value: nil)
        super.init()
        
        setUpRxObservers()
    }
    
    required convenience init(_ isShimmering: Bool) {
        self.init(nil)
        
        self.isShimmering.accept(isShimmering)
    }
    
    internal func notifyDataChanged(_ data: PostModel?) {
        self.profileViewModel.onNext(data?.profileViewModel)
        self.authorName.onNext(data?.author)
        self.publishedAt.onNext(data?.publishedDateString)
        self.thumbnailURL.onNext(data?.firstThumnailURL)
        self.tags.onNext(data?.categories ?? [])
        self.titleText.onNext(data?.title)
        self.contentDesc.onNext(data?.descriptionText)
        self.sereyValue.onNext(data?.sereyValue)
        self.upVoteCount.onNext("\(data?.voterCount ?? 0)")
        self.downVoteCount.onNext("\(data?.flaggerCount ?? 0)")
        self.commentCount.onNext("\(data?.answerCount ?? 0)")
        let isMorePresent = AuthData.shared.isUserLoggedIn ? data?.author == AuthData.shared.username : false
        let isOverAWeek = data?.isOverAWeek ?? false
        self.isMoreHidden.onNext(isOverAWeek || !isMorePresent)
        
        self.isVoteAllowed.accept(data?.author != AuthData.shared.username)
        self.votedType.accept(data?.votedType)
        self.upVoteEnabled.onNext(data?.votedType != .flag)
        self.flagEnabled.onNext(data?.votedType != .upvote)
    }
    
    func onMoreButtonPressed() {
        if let postModel = self.post.value {
            self.shouldShowMoreOption.onNext(postModel)
        }
    }
    
    func onCategoryPressed() {
        if let postModel = self.post.value {
            self.shouldShowPostsByCategory.onNext(postModel)
        }
    }
    
    func onProfilePressed() {
        if let postModel = self.post.value {
            self.shouldShowAuthorProfile.onNext(postModel)
        }
    }
    
    func didUpvotePressed() {
        if self.isVoteAllowed.value {
            handleUpVotePressed()
        }
    }
    
    func didFlagPressed() {
        if self.isVoteAllowed.value {
            handleFlagPressed()
        }
    }
}

// MARK: - Actiion Handlers
extension PostCellViewModel {
    
    internal func handleFlagPressed() {
        if let postModel = self.post.value {
            if let votedType = self.votedType.value {
                self.shouldDownvote.onNext((votedType, postModel))
            } else {
                self.shouldFlag.onNext(postModel)
            }
        }
    }
    
    internal func handleUpVotePressed() {
        if let postModel = self.post.value {
            if let votedType = self.votedType.value {
                self.shouldDownvote.onNext((votedType, postModel))
            } else {
                self.shouldUpVote.onNext(postModel)
            }
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
