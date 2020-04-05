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

class PostCommentViewModel: BaseViewModel, ShimmeringProtocol {
    
    let post: BehaviorRelay<PostModel?>
    let isShimmering: BehaviorRelay<Bool>
    
    let profileViewModel: BehaviorSubject<ProfileViewModel?>
    let upVoteCount: BehaviorSubject<String?>
    let downVoteCount: BehaviorSubject<String?>
    
    let commentTextFieldViewModel: TextFieldViewModel
    
    init(_ postModel: PostModel?) {
        self.post = BehaviorRelay(value: postModel)
        self.isShimmering = BehaviorRelay(value: false)
        self.profileViewModel = BehaviorSubject(value: nil)
        self.upVoteCount = BehaviorSubject(value: nil)
        self.downVoteCount = BehaviorSubject(value: nil)
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
    }
    
    func setUpContentChangedObservers() {
        self.post.asObservable()
            .subscribe(onNext: { [weak self] discussion in
                self?.notifyDataChanged(discussion)
            }) ~ self.disposeBag
    }
}
