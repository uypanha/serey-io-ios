//
//  SlashScreenViewController.swift
//  iOSTemplate
//
//  Created by Phanha Uy on 9/15/19.
//  Copyright © 2019 Phanha Uy. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift

class SlashScreenViewController: BaseViewController {
    
    lazy var viewModel: SlashViewModel = SlashViewModel()
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.setUpRxObservers()
        self.viewModel.checkUserAuth()
    }
}

// MARK: - Setup Rx Observers
fileprivate extension SlashScreenViewController {
    
    func setUpRxObservers() {
        self.setUpShouldPresentObserver()
    }
    
    func setUpShouldPresentObserver() {
        self.viewModel.shouldPresent
            .subscribe(onNext: { viewToPresent in
                switch (viewToPresent) {
                case .loginViewController:
//                    AppDelegate.shared?.rootViewController?.switchToSignIn()
                    break
                case .homeViewController:
                    AppDelegate.shared?.rootViewController?.switchToMainScreen(fadeAnimation: true)
                }
            }).disposed(by: self.disposeBag)
    }
}
