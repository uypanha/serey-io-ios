//
//  PostDetailViewModel.swift
//  SereyIO
//
//  Created by Phanha Uy on 3/6/20.
//  Copyright © 2020 Phanha Uy. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift
import RxBinding

class PostDetailViewModel: BaseCellViewModel, ShouldReactToAction, ShouldPresent, CollectionMultiSectionsProviderModel, DownloadStateNetworkProtocol {
    
    enum Action {
        case morePressed
    }
    
    enum ViewToPresent {
        case moreDialogController(BottomListMenuViewModel)
        case editPostController(CreatePostViewModel)
        case deletePostDialog(confirm: () -> Void)
    }
    
    // input:
    lazy var didActionSubject = PublishSubject<Action>()
    
    // output:
    lazy var shouldPresentSubject = PublishSubject<ViewToPresent>()
    
    let cells: BehaviorRelay<[SectionItem]>
    
    let permlink: BehaviorRelay<String>
    let authorName: BehaviorRelay<String>
    let discussion: BehaviorRelay<PostModel?>
    let replies: BehaviorRelay<[PostModel]>
    
    let postViewModel: BehaviorSubject<PostDetailCellViewModel?>
    let commentPostViewModel: BehaviorSubject<PostCommentViewModel?>
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
        self.commentPostViewModel = BehaviorSubject(value: nil)
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
extension PostDetailViewModel {
    
    enum PostMenu {
        case edit
        case delete
        
        var cellModel: PostMenuCellViewModel {
            return PostMenuCellViewModel(self)
        }
        
        var imageTextModel: ImageTextModel {
            switch self {
            case .edit:
                return ImageTextModel(image: R.image.editIcon(), titleText: "Edit")
            case .delete:
                return ImageTextModel(image: R.image.trashIcon(), titleText: "Delete")
            }
        }
    }
    
    fileprivate func notifyDataChanged(_ data: PostModel?) {
        let postDetailViewModel = data == nil ? PostDetailCellViewModel(true) : PostDetailCellViewModel(data)
        let commentPostViewModel = data == nil ? PostCommentViewModel(true) : PostCommentViewModel(data)
        self.postViewModel.onNext(postDetailViewModel)
        self.commentPostViewModel.onNext(commentPostViewModel)
        self.sereyValueText.onNext(data?.sereyValue ?? "")
        let isMorePresent = AuthData.shared.isUserLoggedIn ? data?.authorName == AuthData.shared.username : false
        self.isMoreHidden.onNext(!isMorePresent)
    }
    
    fileprivate func prepareCells(_ replies: [PostModel]) -> [SectionItem] {
        var cells: [CellViewModel] = []
        cells.append(contentsOf: replies.map { CommentCellViewModel($0) })
        if self.isDownloading.value && replies.isEmpty {
            cells.append(contentsOf: (0...3).map { _ in CommentCellViewModel(true) })
        }
        return [SectionItem(items: cells)]
    }
}

// MARK: - Action Handlers
fileprivate extension PostDetailViewModel {
    
    func handleMorePressed() {
        let items: [PostMenu] = [.edit, .delete]
        let bottomMenuViewModel = BottomListMenuViewModel(items.map { $0.cellModel })
        
        bottomMenuViewModel.shouldSelectMenuItem.asObservable()
            .subscribe(onNext: { [weak self] item in
                if let itemType = (item as? PostMenuCellViewModel)?.type {
                    self?.handleMenuPressed(itemType)
                }
            }) ~ bottomMenuViewModel.disposeBag
        
        self.shouldPresent(.moreDialogController(bottomMenuViewModel))
    }
    
    func handleMenuPressed(_ type: PostMenu) {
        switch type {
        case .edit:
            if let post = self.discussion.value {
                let createPostViewModel = CreatePostViewModel(.edit(post))
                self.shouldPresent(.editPostController(createPostViewModel))
            }
        case .delete:
            self.shouldPresent(.deletePostDialog(confirm: {
                
            }))
        }
    }
}

// MARK: - SetUp RxObservers
extension PostDetailViewModel {
    
    func setUpRxObservers() {
        setUpContentChangedObservers()
        setUpActionObservers()
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
    
    func setUpActionObservers() {
        self.didActionSubject.asObservable()
            .subscribe(onNext: { [weak self] action in
                switch action {
                case .morePressed:
                    self?.handleMorePressed()
                }
            }) ~ self.disposeBag
    }
    
    func setUpCommentViewModelObservers(_ viewModel: PostCommentViewModel) {
        viewModel.shouldUpVote.asObservable()
            .subscribe(onNext: { _ in
                
            }) ~ viewModel.disposeBag
        
        viewModel.shouldComment.asObservable()
            .subscribe(onNext: { comment in
                
            }) ~ viewModel.disposeBag
    }
}

// MARK: - PostMenuCellViewModel
class PostMenuCellViewModel: ImageTextCellViewModel {
    
    let type: PostDetailViewModel.PostMenu
    
    init(_ type: PostDetailViewModel.PostMenu) {
        self.type = type
        super.init(model: type.imageTextModel)
    }
}
