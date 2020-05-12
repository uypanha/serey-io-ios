//
//  CategoryPostsViewController.swift
//  SereyIO
//
//  Created by Panha Uy on 5/9/20.
//  Copyright © 2020 Phanha Uy. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift
import RxBinding

class CategoryPostsViewController: PostTableViewController {
    
    override func setUpRxObservers() {
        super.setUpRxObservers()
        
        shouldPresentObservers()
    }
}

// MARK: - SetUp RxObservers
extension CategoryPostsViewController {
    
    func shouldPresentObservers() {
        self.viewModel.shouldPresent.asObservable()
            .subscribe(onNext: { viewToPresent in
                switch viewToPresent {
                case .editPostController(let editPostViewModel):
                    if let createPostController = R.storyboard.post.createPostViewController() {
                        createPostController.viewModel = editPostViewModel
                        let createPostNavigationController = CloseableNavigationController(rootViewController: createPostController)
                        self.present(createPostNavigationController, animated: true, completion: nil)
                    }
                case .postDetailViewController(let postDetailViewModel):
                    if let postDetailViewController = R.storyboard.post.postDetailViewController() {
                        postDetailViewController.viewModel = postDetailViewModel
                        postDetailViewController.hidesBottomBarWhenPushed = true
                        self.show(postDetailViewController, sender: nil)
                    }
                default:
                    break
                }
            }) ~ self.disposeBag
    }
}
