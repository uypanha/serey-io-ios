//
//  RootViewController.swift
//  iOSTemplate
//
//  Created by Phanha Uy on 9/9/19.
//  Copyright © 2019 Phanha Uy. All rights reserved.
//

import UIKit

class RootViewController: UIViewController {
    
    private var currentViewController: UIViewController
    
    var deeplink: DeeplinkType? {
        didSet {
            handleDeeplink()
        }
    }
    
    init() {
        let splashScreenViewController = R.storyboard.slash.slashScreenViewController()
        self.currentViewController = splashScreenViewController!
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        self.presentViewController(viewController: self.currentViewController)
    }
}

// MARK: - Switching Screens
extension RootViewController {
    
    func switchToMainScreen(fadeAnimation: Bool = false) {
//        let mainTabBarViewController = MainTabBarViewController()
//        mainTabBarViewController.viewModel = MainTabBarViewModel()
//        if fadeAnimation {
//            self.animateFadeTransition(to: mainTabBarViewController) { [weak self] in
//                self?.handleDeeplink()
//            }
//        } else {
//            self.animateSlideToTopTransition(to: mainTabBarViewController) { [weak self] in
//                self?.handleDeeplink()
//            }
//        }
    }
}

// MARK: - Preparations & Tools
extension RootViewController {
    
    private func presentViewController(viewController: UIViewController) {
        self.addChild(viewController)
        viewController.view.frame = self.view.bounds
        self.view.addSubview(viewController.view)
        viewController.didMove(toParent: self)
    }
    
    private func changeCurrentViewController(newViewController: UIViewController) {
        
        self.currentViewController.willMove(toParent: nil)
        self.currentViewController.view.removeFromSuperview()
        self.currentViewController.removeFromParent()
        
        self.currentViewController = newViewController
    }
    
    private func animateFadeTransition(to new: UIViewController, completion: (() -> Void)? = nil) {
        new.view.frame = self.view.bounds
        self.currentViewController.willMove(toParent: nil)
        self.addChild(new)
        
        let moveFrom = self.currentViewController
        self.currentViewController = new
        
        transition(from: moveFrom, to: new, duration: 0.3, options: [.transitionCrossDissolve, .curveEaseOut], animations: {
        }) { completed in
            moveFrom.view.removeFromSuperview()
            moveFrom.removeFromParent()
            
            new.didMove(toParent: self)
            completion?()
        }
    }
    
    private func animateSlideToTopTransition(to newController: UIViewController, completion: (() -> Void)? = nil) {
        let initialFrame = CGRect(x: 0, y: view.bounds.height, width: view.bounds.width, height: view.bounds.height)
        self.currentViewController.willMove(toParent: nil)
        self.addChild(newController)
        
        let moveFrom = self.currentViewController
        self.currentViewController = newController
        
        newController.view.frame = initialFrame
        
        transition(from: moveFrom, to: newController, duration: 0.3, options: [], animations: {
            newController.view.frame = self.view.bounds
        }) { completed in
            moveFrom.view.removeFromSuperview()
            moveFrom.removeFromParent()
            
            newController.didMove(toParent: self)
            completion?()
        }
    }
    
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
