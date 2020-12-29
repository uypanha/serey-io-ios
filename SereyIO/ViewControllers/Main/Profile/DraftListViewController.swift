//
//  DraftListViewController.swift
//  SereyIO
//
//  Created by Panha Uy on 12/24/20.
//  Copyright © 2020 Phanha Uy. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift
import RxBinding

class DraftListViewController: ListTableViewController<DraftListViewModel> {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setUpRxObservers()
    }
}

// MARK: - SetUp RxObservers
extension DraftListViewController {
    
    func setUpRxObservers() {
        setUpViewToPresentObservers()
    }
    
    func setUpViewToPresentObservers() {
        self.viewModel.shouldPresent.asObservable()
            .subscribe(onNext: { [weak self] viewToPresent in
                switch viewToPresent {
                case .editDraftController(let createPostViewModel):
                    if let createPostViewController = R.storyboard.post.createPostViewController() {
                        createPostViewController.viewModel = createPostViewModel
                        let createPostNavigationController = CloseableNavigationController(rootViewController: createPostViewController)
                        self?.present(createPostNavigationController, animated: true, completion: nil)
                    }
                }
            }) ~ self.disposeBag
    }
}
