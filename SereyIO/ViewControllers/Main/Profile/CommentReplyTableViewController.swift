//
//  CommentReplyTableViewController.swift
//  SereyIO
//
//  Created by Panha Uy on 4/25/20.
//  Copyright © 2020 Serey IO. All rights reserved.
//

import UIKit
import RxBinding

class CommentReplyTableViewController: ListTableViewController<CommentsListViewModel> {
    
    var scrollViewDelegate: UIScrollViewDelegate?
    
    override func viewDidLoad() {
        self.sepereatorStyle = .none
        self.contentInset = UIEdgeInsets(top: 8, left: 0, bottom: 8, right: 0)
        super.viewDidLoad()
        
        setUpShouldPresentErrorObservers()
    }
    
    func setUpShouldPresentErrorObservers() {
        self.viewModel.shouldPresentError.asObservable()
            .subscribe(onNext: { [unowned self] errorInfo in
                if self.viewModel.comments.value.isEmpty {
                    self.prepareToDisplayEmptyView(self.viewModel.prepareEmptyViewModel(errorInfo))
                } else {
                    self.showDialogError(errorInfo, positiveButton: R.string.common.tryAgain.localized(), positiveCompletion: {
                        self.viewModel.downloadData()
                    }, negativeButton: R.string.common.cancel.localized())
                }
            }) ~ self.disposeBag
    }
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.scrollViewDelegate?.scrollViewDidScroll?(scrollView)
    }
    
    override func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        self.scrollViewDelegate?.scrollViewWillBeginDragging?(scrollView)
    }
}
