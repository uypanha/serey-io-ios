//
//  MoreAppsViewController.swift
//  SereyIO
//
//  Created by Panha Uy on 4/30/20.
//  Copyright © 2020 Phanha Uy. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift
import RxBinding

class MoreAppsViewController: ListTableViewController<MoreAppsViewModel> {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        setUpRxObservers()
    }
}

// MARK: - SetUp RxObservers
extension MoreAppsViewController {
    
    func setUpRxObservers() {
        self.viewModel.shouldPresent.asObservable()
            .subscribe(onNext: { viewToPresent in
                switch viewToPresent {
                case .openSereyURL(let url):
                    UIApplication.shared.open(url)
                }
            }) ~ self.disposeBag
    }
}
