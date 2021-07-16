//
//  RootViewController.swift
//  SereyIO
//
//  Created by Phanha Uy on 9/9/19.
//  Copyright © 2020 Serey IO. All rights reserved.
//

import UIKit

class RootViewController: BaseRootViewController {
    
    var deeplink: DeeplinkType? {
        didSet {
            handleDeeplink()
        }
    }
    
    init() {
        let splashScreenViewController = R.storyboard.slash.slashScreenViewController()
        super.init(splashScreenViewController!)
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Switching Screens
extension RootViewController {
    
    func switchToMainScreen(fadeAnimation: Bool = false) {
        let mainTabBarViewController = MainTabBarViewController()
//        mainTabBarViewController.viewModel = MainTabBarViewModel()
        if fadeAnimation {
            self.animateFadeTransition(to: mainTabBarViewController) { [weak self] in
                self?.handleDeeplink()
            }
        } else {
            self.animateSlideToTopTransition(to: mainTabBarViewController) { [weak self] in
                self?.handleDeeplink()
            }
        }
    }
    
    func switchToSelectLanguageBoardScreen() {
        if let selectLanguageBoardViewController = R.storyboard.onBoard.selectLanguageViewController() {
            selectLanguageBoardViewController.viewModel = SelectLanguageViewModel()
            self.animateFadeTransition(to: selectLanguageBoardViewController)
        }
    }
    
    func switchToBoardingScreen() {
        if let boardingViewController = R.storyboard.onBoard.onBoardingViewController() {
            boardingViewController.viewModel = .init()
            self.animateFadeTransition(to: UINavigationController(rootViewController: boardingViewController).then {
                $0.removeNavigationBarBorder()
            })
        }
    }
}

// MARK: - Preparations & Tools
extension RootViewController {
    
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
