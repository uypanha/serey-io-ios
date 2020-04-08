//
//  PostCommentViewModel.swift
//  SereyIO
//
//  Created by Panha Uy on 4/5/20.
//  Copyright © 2020 Phanha Uy. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift
import RxBinding

class PostCommentViewModel: BaseViewModel, ShimmeringProtocol, ShouldReactToAction {
    
    enum Action {
        case upVotePressed
        case downVotePressed
        case sendCommentPressed
    }
    
    // input:
    lazy var didActionSubject = PublishSubject<Action>()
    
    let post: BehaviorRelay<PostModel?>
    let isShimmering: BehaviorRelay<Bool>
    
    let profileViewModel: BehaviorSubject<ProfileViewModel?>
    let upVoteCount: BehaviorSubject<String?>
    let downVoteCount: BehaviorSubject<String?>
    
    let shouldComment: PublishSubject<String>
    let shouldUpVote: PublishSubject<Void>
    let shouldDownVote: PublishSubject<Void>
    let isUploading: BehaviorSubject<Bool>
    
    let commentTextFieldViewModel: TextFieldViewModel
    
    init(_ postModel: PostModel?) {
        self.post = BehaviorRelay(value: postModel)
        self.isShimmering = BehaviorRelay(value: false)
        self.profileViewModel = BehaviorSubject(value: nil)
        self.upVoteCount = BehaviorSubject(value: nil)
        self.downVoteCount = BehaviorSubject(value: nil)
        
        self.shouldComment = PublishSubject()
        self.shouldUpVote = PublishSubject()
        self.shouldDownVote = PublishSubject()
        self.isUploading = BehaviorSubject(value: false)
        
        self.commentTextFieldViewModel = TextFieldViewModel.textFieldWith(title: R.string.post.postAComment.localized(), errorMessage: nil, validation: .notEmpty)
        super.init()
        
        setUpRxObservers()
    }
    
    required convenience init(_ isShimmering: Bool) {
        self.init(nil)
        
        self.isShimmering.accept(isShimmering)
    }
    
    func updateData(_ data: PostModel) {
        self.post.accept(data)
        self.isShimmering.accept(false)
    }
    
    internal func notifyDataChanged(_ data: PostModel?) {
        self.profileViewModel.onNext(AuthData.shared.loggedUserModel?.profileModel)
        self.upVoteCount.onNext("\(data?.upvote ?? 0)")
        self.downVoteCount.onNext("\(data?.flag ?? 0)")
    }
}

// MARK: - SetUp RxObservers
fileprivate extension PostCommentViewModel {
    
    func setUpRxObservers() {
        setUpContentChangedObservers()
        setUpActionObservers()
    }
    
    func setUpContentChangedObservers() {
        self.post.asObservable()
            .subscribe(onNext: { [weak self] discussion in
                self?.notifyDataChanged(discussion)
            }) ~ self.disposeBag
    }
    
    func setUpActionObservers() {
        self.didActionSubject.asObservable()
            .subscribe(onNext: { [weak self] action in
                switch action {
                case .upVotePressed:
                    self?.shouldUpVote.onNext(())
                case .downVotePressed:
                    self?.shouldDownVote.onNext(())
                case .sendCommentPressed:
                    let comment = self?.commentTextFieldViewModel.value ?? ""
                    self?.shouldComment.onNext(comment)
                }
            }) ~ self.disposeBag
    }
}
