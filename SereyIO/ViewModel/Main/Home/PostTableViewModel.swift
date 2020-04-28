//
//  PostTableViewModel.swift
//  SereyIO
//
//  Created by Phanha Uy on 2/6/20.
//  Copyright © 2020 Phanha Uy. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift
import RxBinding
import RxDataSources

class PostTableViewModel: BasePostViewModel, ShouldReactToAction, ShouldPresent, ShouldRefreshProtocol {
    
    enum Action {
        case itemSelected(IndexPath)
        case refresh
    }
    
    enum ViewToPresent {
        case loading(Bool)
        case postDetailViewController(PostDetailViewModel)
        case moreDialogController(BottomListMenuViewModel)
        case editPostController(CreatePostViewModel)
        case deletePostDialog(confirm: () -> Void)
    }
    
    // input:
    lazy var didActionSubject = PublishSubject<Action>()
    
    // output:
    lazy var shouldPresentSubject = PublishSubject<PostTableViewModel.ViewToPresent>()
    
    override init(_ type: DiscussionType) {
        super.init(type)
        
        setUpRxObservers()
    }
    
    func shouldRefreshData() {
        self.didAction(with: .refresh)
    }
    
    override func onMorePressed(of postModel: PostModel) {
        let items: [PostMenu] = [.edit, .delete]
        let bottomMenuViewModel = BottomListMenuViewModel(items.map { $0.cellModel })
        
        bottomMenuViewModel.shouldSelectMenuItem.asObservable()
            .subscribe(onNext: { [weak self] item in
                if let itemType = (item as? PostMenuCellViewModel)?.type {
                    self?.handleMenuPressed(itemType, postModel)
                }
            }) ~ bottomMenuViewModel.disposeBag
        
        self.shouldPresent(.moreDialogController(bottomMenuViewModel))
    }
}

// MARK: - Networks
extension PostTableViewModel {
    
    private func deletePost(_ post: PostModel) {
        self.shouldPresent(.loading(true))
        self.discussionService.deletePost(post.authorName, post.permlink)
            .subscribe(onNext: { [weak self] _ in
                self?.shouldPresent(.loading(false))
            }, onError: { [weak self] error in
                self?.shouldPresent(.loading(false))
                let errorInfo = ErrorHelper.prepareError(error: error)
                self?.shouldPresentError(errorInfo)
            }) ~ self.disposeBag
    }
}

// MARK: - Action Handlers
fileprivate extension PostTableViewModel {
    
    func handleItemPressed(_ indexPath: IndexPath) {
        if let item = self.item(at: indexPath) as? PostCellViewModel {
            if let discussion = item.post.value {
                let viewModel = PostDetailViewModel(discussion)
                self.shouldPresent(.postDetailViewController(viewModel))
            }
        }
    }
    
    func handleMenuPressed(_ type: PostMenu, _ post: PostModel) {
        switch type {
        case .edit:
            let createPostViewModel = CreatePostViewModel(.edit(post))
            self.shouldPresent(.editPostController(createPostViewModel))
        case .delete:
            self.shouldPresent(.deletePostDialog(confirm: {
                self.deletePost(post)
            }))
        }
    }
}

// MARK: - SetUp RxObservers
fileprivate extension PostTableViewModel {
    
    func setUpRxObservers() {
        setUpActionObservers()
    }
    
    func setUpActionObservers() {
        self.didActionSubject.asObservable()
            .subscribe(onNext: { [weak self] action in
                switch action {
                case .itemSelected(let indexPath):
                    self?.handleItemPressed(indexPath)
                case .refresh:
                    self?.reset()
                    self?.discussions.renotify()
                }
            }) ~ self.disposeBag
    }
}
