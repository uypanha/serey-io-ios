//
//  WalletRootViewController.swift
//  SereyIO
//
//  Created by Panha Uy on 6/27/20.
//  Copyright © 2020 Phanha Uy. All rights reserved.
//

import UIKit

class WalletRootViewController: BaseRootViewController {
    
    var deeplink: DeeplinkType? {
        didSet {
            handleDeeplink()
        }
    }
    
    init() {
//        let signUpWalletViewController = R.storyboard.auth.signUpWalletViewController()
//        signUpWalletViewController?.viewModel = SignUpWalletViewModel()
        let mainWalletViewController = R.storyboard.wallet.walletViewController()
        mainWalletViewController?.viewModel = WalletViewModel()
        super.init(CloseableNavigationController(rootViewController: mainWalletViewController!))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Switching Screens
extension WalletRootViewController {
    
    func switchToMainScreen(fadeAnimation: Bool = true) {
        let mainWalletViewController = R.storyboard.wallet.walletViewController()!
        let closableViewController = CloseableNavigationController(rootViewController: mainWalletViewController)
        if fadeAnimation {
            self.animateFadeTransition(to: closableViewController) { [weak self] in
                self?.handleDeeplink()
            }
        } else {
            self.animateSlideToTopTransition(to: closableViewController) { [weak self] in
                self?.handleDeeplink()
            }
        }
    }
}

// MARK: - Preparations & Tools
extension WalletRootViewController {
    
    private func handleDeeplink() {
        if let deeplink = self.deeplink {
            switch deeplink {
            case .browser(let url):
                let webViewViewController = WebViewViewController()
                webViewViewController.viewModel = WebViewViewModel(withURLToLoad: url, title: "")
                self.present(UINavigationController(rootViewController: webViewViewController), animated: true, completion: nil)
                
                // reset the deeplink back no nil, so it will not be triggered more than once
                self.deeplink = nil
            default:
//                if let mainNavigationController = currentViewController as? MainNavigationViewController {
//
//                    mainNavigationController.handleDeeplink(deeplink)
//
//                    // reset the deeplink back no nil, so it will not be triggered more than once
//                    self.deeplink = nil
//                }
                break
            }
        }
    }
}
