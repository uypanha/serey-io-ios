//
//  CommentTextViewModel.swift
//  SereyIO
//
//  Created by Panha Uy on 4/16/20.
//  Copyright © 2020 Phanha Uy. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift
import RxBinding

class CommentTextViewModel: BaseViewModel, ShouldReactToAction {
    
    enum Action {
        case sendCommentPressed
    }
    
    // input:
    lazy var didActionSubject = PublishSubject<CommentTextViewModel.Action>()
    
    let commentTextFieldViewModel: TextFieldViewModel
    let shouldSendComment: PublishSubject<String>
    
    let isUploading: BehaviorSubject<Bool>
    
    override init() {
        self.commentTextFieldViewModel = TextFieldViewModel.textFieldWith(title: R.string.post.postAComment.localized())
        self.shouldSendComment = PublishSubject()
        self.isUploading = BehaviorSubject(value: false)
        super.init()
        
        setUpRxObservers()
    }
}

// MARK: - SetUp RxObservers
extension CommentTextViewModel {
    
    func setUpRxObservers() {
        setUpActionObservers()
    }
    
    func setUpActionObservers() {
        self.didActionSubject.asObservable()
            .subscribe(onNext: { [weak self] action in
                switch action {
                case .sendCommentPressed:
                    let comment = self?.commentTextFieldViewModel.value ?? ""
                    self?.shouldSendComment.onNext(comment)
                }
            }) ~ self.disposeBag
    }
}
