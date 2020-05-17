//
//  VotersViewController.swift
//  SereyIO
//
//  Created by Panha Uy on 5/17/20.
//  Copyright © 2020 Phanha Uy. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift
import RxBinding
import RxDataSources

class VotersViewController: ListTableViewController<VoterListViewModel> {

    override func viewDidLoad() {
        self.contentInset = UIEdgeInsets(top: 16, left: 0, bottom: 8, right: 0)
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
//        setUpRxObservers()
    }
}

//// MARK: - SetUp RxObservers
//fileprivate extension VotersViewController {
//
//    func setUpRxObservers() {
//        setUpShouldPresentObservers()
//    }
//
//    func setUpShouldPresentObservers() {
//        self.viewModel.shouldPresent.asObservable()
//            .subscribe(onNext: { [weak self] viewToPresent in
//                switch viewToPresent {
//                case .userAccountController(let userAccountViewMoel):
//                    if let userAccountViewController = R.storyboard.profile.userAccountViewController() {
//                        userAccountViewController.viewModel = userAccountViewMoel
//                        self?.show(userAccountViewController, sender: nil)
//                    }
//                }
//            }) ~ self.disposeBag
//    }
//}
