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

class PostDetailViewModel: BaseCellViewModel, CollectionMultiSectionsProviderModel, DownloadStateNetworkProtocol {
    
    let cells: BehaviorRelay<[SectionItem]>
    
    let permlink: BehaviorRelay<String>
    let authorName: BehaviorRelay<String>
    let discussion: BehaviorRelay<PostModel?>
    let replies: BehaviorRelay<[PostModel]>
    
    let postViewModel: BehaviorSubject<PostCellViewModel?>
    let sereyValueText: BehaviorSubject<String>
    let isMoreHidden: BehaviorSubject<Bool>
    
    let discussionService: DiscussionService
    let isDownloading: BehaviorRelay<Bool>
    
    init(_ permlink: String, _ authorName: String) {
        self.permlink = BehaviorRelay(value: permlink)
        self.authorName = BehaviorRelay(value: authorName)
        self.discussion = BehaviorRelay(value: nil)
        self.replies = BehaviorRelay(value: [])
        
        self.postViewModel = BehaviorSubject(value: nil)
        self.sereyValueText = BehaviorSubject(value: "")
        self.isMoreHidden = BehaviorSubject(value: true)
        
        self.cells = BehaviorRelay(value: [])
        self.discussionService = DiscussionService()
        self.isDownloading = BehaviorRelay(value: false)
        super.init()
        
        setUpRxObservers()
    }
    
    convenience init(_ discussion: PostModel) {
        self.init(discussion.permlink, discussion.authorName)
        self.discussion.accept(discussion)
    }
}

// MARK: - Networks
extension PostDetailViewModel {
    
    func downloadData() {
        if !self.isDownloading.value {
            self.isDownloading.accept(true)
            self.fetchPostDetial()
        }
    }
    
    private func fetchPostDetial() {
        self.replies.renotify()
        self.discussionService.getPostDetail(permlink: self.permlink.value, authorName: self.authorName.value)
            .subscribe(onNext: { [weak self] response in
                self?.isDownloading.accept(false)
                self?.replies.accept(response.replies)
            }, onError: { [weak self] error in
                self?.isDownloading.accept(false)
                let errorInfo = ErrorHelper.prepareError(error: error)
                self?.shouldPresentError(errorInfo)
            }) ~ self.disposeBag
    }
}

// MARK: - Preparations & Tools
fileprivate extension PostDetailViewModel {
    
    func notifyDataChanged(_ data: PostModel?) {
        let postDetailViewModel = data == nil ? PostCellViewModel(true) : PostCellViewModel(data)
        self.postViewModel.onNext(postDetailViewModel)
        self.sereyValueText.onNext(data?.sereyValue ?? "")
        let isMorePresent = AuthData.shared.isUserLoggedIn ? data?.authorName == AuthData.shared.username : false
        self.isMoreHidden.onNext(!isMorePresent)
    }
    
    func prepareCells(_ replies: [PostModel]) -> [SectionItem] {
        var cells: [CellViewModel] = []
        cells.append(contentsOf: replies.map { CommentCellViewModel($0) })
        if self.isDownloading.value && replies.isEmpty {
            cells.append(contentsOf: (0...3).map { _ in CommentCellViewModel(true) })
        }
        return [SectionItem(items: cells)]
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
        
        self.replies.asObservable()
            .map { self.prepareCells($0) }
            ~> self.cells
            ~ self.disposeBag
    }
}
