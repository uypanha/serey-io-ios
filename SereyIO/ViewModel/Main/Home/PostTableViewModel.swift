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
        case postDetailViewController(PostDetailViewModel)
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
