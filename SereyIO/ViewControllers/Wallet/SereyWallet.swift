//
//  SereyWallet.swift
//  SereyIO
//
//  Created by Panha Uy on 6/17/20.
//  Copyright © 2020 Phanha Uy. All rights reserved.
//

import UIKit

class SereyWallet {
    
    var walletViewController: UIViewController
    
    init() {
        self.walletViewController = UIViewController()
        prepareViewController()
    }
}

// MARK: - Preparations & Tools
extension SereyWallet {
    
    private func prepareViewController() {
        self.walletViewController = signUpWalletController()
    }
    
    private func signUpWalletController() -> UIViewController {
        let viewcontroller = R.storyboard.auth.signUpWalletViewController()!
        viewcontroller.viewModel = SignUpWalletViewModel()
        return viewcontroller
    }
}
