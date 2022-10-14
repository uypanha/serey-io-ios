//
//  DownvoteDialogViewModel.swift
//  SereyIO
//
//  Created by Panha Uy on 4/22/20.
//  Copyright © 2020 Serey IO. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift
import RxBinding

class DownvoteDialogViewModel: BaseViewModel, ShouldReactToAction {
    
    enum DownVoteType {
        case upVoteComment
        case flagComment
        case upvotePost
        case flagPost
        
        var title: String {
            switch self {
            case .upvotePost, .upVoteComment:
                return R.string.post.confirmRemoveVote.localized()
            case .flagComment, .flagPost:
                return R.string.post.confirmRemoveFlage.localized()
            }
        }
        
        var message: String {
            switch self {
            case .upvotePost, .flagPost:
                return R.string.post.removeVotePostMessage.localized()
            case .upVoteComment, .flagComment:
                return R.string.post.removeVoteCommentMessage.localized()
            }
        }
    }
    
    enum Action {
        case confirmPressed
    }
    
    lazy var didActionSubject = PublishSubject<Action>()
    
    let downVoteType: BehaviorRelay<DownVoteType>
    let titleText: BehaviorSubject<String?>
    let messageText: BehaviorSubject<String?>
    
    let shouldConfirm: PublishSubject<Void>
    
    init(_ downVoteType: DownVoteType) {
        self.downVoteType = BehaviorRelay(value: downVoteType)
        self.titleText = BehaviorSubject(value: nil)
        self.messageText = BehaviorSubject(value: nil)
        self.shouldConfirm = PublishSubject()
        super.init()
        
        setUpRxObservers()
    }
}

// MARK: - SetUp RxObservers
fileprivate extension DownvoteDialogViewModel {
    
    func setUpRxObservers() {
        setUpContentChangedObservers()
        setUpActionObservers()
    }
    
    func setUpContentChangedObservers() {
        self.downVoteType.asObservable()
            .map { $0.title }
            ~> self.titleText
            ~ self.disposeBag
        
        self.downVoteType.asObservable()
            .map { $0.message }
            ~> self.messageText
            ~ self.disposeBag
    }
    
    func setUpActionObservers() {
        self.didActionSubject.asObservable()
            .subscribe(onNext: { [weak self] action in
                switch action {
                case .confirmPressed:
                    self?.shouldConfirm.onNext(())
                }
            }) ~ self.disposeBag
    }
}
