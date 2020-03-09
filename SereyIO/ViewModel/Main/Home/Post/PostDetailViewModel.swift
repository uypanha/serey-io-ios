//
//  PostDetailViewModel.swift
//  SereyIO
//
//  Created by Phanha Uy on 3/6/20.
//  Copyright © 2020 Phanha Uy. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift
import RxBinding

class PostDetailViewModel: BaseCellViewModel, CollectionMultiSectionsProviderModel {
    
    let cells: BehaviorRelay<[SectionItem]>
    
    let discussion: BehaviorRelay<PostModel?>
    let replies: BehaviorRelay<[PostModel]>
    
    let postViewModel: BehaviorSubject<PostCellViewModel?>
    let sereyValueText: BehaviorSubject<String>
    
    let discussionService: DiscussionService
    
    init(_ discussion: PostModel) {
        self.discussion = BehaviorRelay(value: discussion)
        self.replies = BehaviorRelay(value: [])
        self.postViewModel = BehaviorSubject(value: nil)
        self.sereyValueText = BehaviorSubject(value: "")
        
        self.cells = BehaviorRelay(value: [])
        self.discussionService = DiscussionService()
        super.init()
        
        setUpRxObservers()
    }
}



// MARK: - Preparations & Tools
fileprivate extension PostDetailViewModel {
    
    func notifyDataChanged(_ data: PostModel?) {
        let postDetailViewModel = data == nil ? PostCellViewModel(true) : PostCellViewModel(data)
        self.postViewModel.onNext(postDetailViewModel)
        self.sereyValueText.onNext(data?.sereyValue ?? "")
    }
    
    func prepareCells(_ replies: [PostModel]) -> [SectionItem] {
        return [SectionItem(items: replies.map { CommentCellViewModel($0) })]
    }
}

// MARK: - SetUp RxObservers
extension PostDetailViewModel {
    
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
