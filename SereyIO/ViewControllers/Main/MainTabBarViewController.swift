//
//  MainTabBarViewController.swift
//  SereyIO
//
//  Created by Phanha Uy on 2/2/20.
//  Copyright © 2020 Serey IO. All rights reserved.
//

import UIKit

class MainTabBarViewController: BaseTabBarViewController, VoteDialogProtocol {
    
    private var previousController: UIViewController? = nil

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setUpViews()
        setUpRxObservers()
    }
    
    override func setUpLocalizedTexts() {
        if let viewControllers = self.viewControllers {
            for i in 0..<viewControllers.count {
                ((viewControllers[i] as? UINavigationController)?.viewControllers.first as? TabBarControllerDelegate)?.configureTabBar(i)
            }
        }
    }
}

// MARK: - Preparations & Tools
fileprivate extension MainTabBarViewController {
    
    enum ControllerType: Int, CaseIterable {
        case home = 0, search, notifications, more
        
        func prepareViewController() -> UIViewController {
            var viewController: UIViewController? = nil
            
            switch self {
            case .home:
                viewController = R.storyboard.home.homeViewController()
                (viewController as? HomeViewController)?.viewModel = .init()
            case .search:
                viewController = R.storyboard.search.searchViewController()
                (viewController as? SearchViewController)?.viewModel = .init()
            case .notifications:
                viewController = NotificationViewController()
                (viewController as? NotificationViewController)?.viewModel = .init()
            case .more:
                viewController = R.storyboard.more.moreViewController()
                (viewController as? MoreViewController)?.viewModel = .init()
            }
            
            return viewController ?? UIViewController()
        }
    }
    
    func setUpViews() {
        configureTabBarController()
        self.delegate = self
    }
    
    func configureTabBarController() {
        let controllers: [UIViewController] = ControllerType.allCases.map { $0.prepareViewController() }
        
        for i in 0..<controllers.count {
            (controllers[i] as? TabBarControllerDelegate)?.configureTabBar(i)
        }
        
        viewControllers = controllers.map({ viewController -> UIViewController in
            return UINavigationController(rootViewController: viewController)
        })
    }
}

// MARK: - Action Navigations & Tools
extension MainTabBarViewController {
    
    func handleDeeplink(_ deeplink: DeeplinkType) {
        switch deeplink {
        case .post(let permlink, let author):
            if let navVC = (self.selectedViewController as? UINavigationController) {
                if let postDetailViewController = R.storyboard.post.postDetailViewController() {
                    postDetailViewController.viewModel = .init(permlink, author)
                    postDetailViewController.hidesBottomBarWhenPushed = true
                    navVC.pushViewController(postDetailViewController, animated: true)
                }
            }
        case .followFrom(let username):
            if let navVC = (self.selectedViewController as? UINavigationController) {
                if let accountViewController = R.storyboard.profile.userAccountViewController() {
                    accountViewController.viewModel = .init(username)
                    accountViewController.hidesBottomBarWhenPushed = true
                    navVC.show(accountViewController, sender: nil)
                }
            }
        default:
            break
        }
    }
}

// MARK: - UITabBarControllerDelegate
extension MainTabBarViewController: UITabBarControllerDelegate {

    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        if let navigationViewController = viewController as? UINavigationController {
            if let viewController = navigationViewController.viewControllers.first {
                self.previousController = viewController
            }
        }
    }
}

// MARK: - SetUp RxObservers
 fileprivate extension MainTabBarViewController {
    
    func setUpRxObservers() {
        setUpControlsObservers()
        setUpViewToPresentObservers()
    }
    
    func setUpControlsObservers() {
    }
    
    func setUpViewToPresentObservers() {
    }
}
