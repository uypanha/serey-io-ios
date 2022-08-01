//
//  DrumDetailViewModel.swift
//  SereyIO
//
//  Created by Panha Uy on 20/7/22.
//  Copyright © 2022 Serey IO. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift
import RxBinding

class DrumDetailViewModel: BaseViewModel,
                           DownloadStateNetworkProtocol,
                           CollectionMultiSectionsProviderModel,
                           ShouldReactToAction,
                           ShouldPresent {
    
    enum Action {
        case didBeginToComment
    }
    
    enum ViewToPresent {
        case signInViewController
    }
    
    // input:
    let didActionSubject: PublishSubject<Action>
    
    // output:
    let shouldPresentSubject: PublishSubject<ViewToPresent>
    
    let cells: BehaviorRelay<[SectionItem]>
    
    let author: String
    let permlink: String
    let drum: BehaviorRelay<DrumModel?>
    let replies: BehaviorRelay<[PostModel]>
    
    let drumDetailCellModel: DrumsPostCellViewModel
    let commentViewModel: CommentTextViewModel
    
    let isDownloading: BehaviorRelay<Bool>
    let drumService: DrumsService
    let discussionService: DiscussionService
    
    init(author: String, permlink: String) {
        self.didActionSubject = .init()
        self.shouldPresentSubject = .init()
        
        self.cells = .init(value: [])
        self.drum = .init(value: nil)
        self.replies = .init(value: [])
        
        self.author = author
        self.permlink = permlink
        
        self.drumDetailCellModel = .init(nil)
        self.commentViewModel = .init()
        self.drumService = .init()
        self.discussionService = .init()
        self.isDownloading = .init(value: false)
        super.init()
        
        setUpRxObservers()
    }
    
    convenience init(_ drum: DrumModel) {
        self.init(author: drum.author, permlink: drum.permlink)

        self.drum.accept(drum)
        self.drumDetailCellModel.update(drum: drum)
    }
}

// MARK: - Networks
extension DrumDetailViewModel {
    
    func downloadData() {
        if !self.isDownloading.value {
            self.isDownloading.accept(true)
            self.fetchDrumDetail()
        }
    }
    
    func fetchDrumDetail() {
        self.drumService.fetchDrumDetail(author: self.author, permlink: self.permlink)
            .subscribe(onNext: { [weak self] data in
                self?.isDownloading.accept(false)
                self?.drum.accept(data.content)
                self?.replies.accept(data.replies)
            }, onError: { [weak self] error in
                self?.isDownloading.accept(false)
                self?.shouldPresentError(ErrorHelper.prepareError(error: error))
            }) ~ self.disposeBag
    }
    
    internal func submitComment(_ comment: String) {
        let submitCommentModel = self.prepareSubmitCommentModel(comment)
        self.commentViewModel.isUploading.onNext(true)
        self.discussionService.submitComment(submitCommentModel)
            .subscribe(onNext: { [weak self] _ in
                self?.commentViewModel.isUploading.onNext(false)
                self?.fetchDrumDetail()
                self?.commentViewModel.clearInput()
            }, onError: { [weak self] error in
                self?.isDownloading.accept(false)
                self?.commentViewModel.isUploading.onNext(false)
                let errorInfo = ErrorHelper.prepareError(error: error)
                self?.shouldPresentError(errorInfo)
            }) ~ self.disposeBag
    }
    
    internal func prepareSubmitCommentModel(_ comment: String) -> SubmitCommentModel {
        let permlink = self.drum.value?.permlink ?? ""
        let author = self.drum.value?.author ?? ""
        let title = self.postTitle()
        let category = self.drum.value?.categories?.first ?? ""
        
        return SubmitCommentModel(parentAuthor: author, parentPermlink: permlink, title: title, body: comment, mainCategory: category)
    }
    
    internal func postTitle() -> String {
        return self.drum.value?.title ?? ""
    }
}

// MARK: - Preparations & Tools
private extension DrumDetailViewModel {
    
    func prepareCells() -> [SectionItem] {
        var items: [CellViewModel] = self.replies.value.map { DrumReplyCellViewModel(reply: $0) }
        var repliesHeader: String? = items.isEmpty ? nil : "Replies"
        if self.isDownloading.value {
            if items.isEmpty {
                repliesHeader = "Replies"
                items.append(contentsOf: (0..<4).map { _ in DrumReplyCellViewModel() })
            }
        } else {
            items.append(NoMorePostCellViewModel("You reach the end"))
        }
        return [.init(model: .init(header: repliesHeader),items: items)]
    }
}

// MARK: - SetUp RxObservers
private extension DrumDetailViewModel {
    
    func setUpRxObservers() {
        setUpContentChangedObservers()
        setUpActionObservers()
    }
    
    func setUpContentChangedObservers() {
        self.drum.asObservable()
            .subscribe(onNext: { [weak self] drum in
                self?.drumDetailCellModel.update(drum: drum)
            }) ~ self.disposeBag
        
        self.replies.asObservable()
            .map { _ in self.prepareCells() }
            ~> self.cells
            ~ self.disposeBag
        
        self.isDownloading.asObservable()
            .filter { $0 }
            .map { _ in self.prepareCells() }
            ~> self.cells
            ~ self.disposeBag
        
        self.commentViewModel.shouldSendComment.asObservable()
            .subscribe(onNext: { [weak self] text in
                self?.submitComment(text)
            }) ~ self.disposeBag
    }
    
    func setUpActionObservers() {
        self.didActionSubject.asObservable()
            .subscribe(onNext: { [weak self] action in
                switch action {
                case .didBeginToComment:
                    if !AuthData.shared.isUserLoggedIn {
                        self?.shouldPresent(.signInViewController)
                    }
                }
            }) ~ self.disposeBag
    }
}
