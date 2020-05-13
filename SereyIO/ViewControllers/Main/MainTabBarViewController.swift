//
//  MainTabBarViewController.swift
//  SereyIO
//
//  Created by Phanha Uy on 2/2/20.
//  Copyright © 2020 Phanha Uy. All rights reserved.
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
                (viewController as? HomeViewController)?.viewModel = HomeViewModel()
            case .search:
                viewController = R.storyboard.search.searchViewController()
                (viewController as? SearchViewController)?.viewModel = SearchViewModel()
            case .notifications:
                viewController = NotificationViewController()
            case .more:
                viewController = R.storyboard.more.moreViewController()
                (viewController as? MoreViewController)?.viewModel = MoreViewModel()
            }
            
            return viewController ?? UIViewController()
        }
    }
    
    func setUpViews() {
        configureTabBarController()
        self.delegate = self
    }
    
    func configureTabBarController() {
        let controllers: [UIViewController] = [ControllerType.home, .search, .more].map { $0.prepareViewController() }
        
        for i in 0..<controllers.count {
            (controllers[i] as? TabBarControllerDelegate)?.configureTabBar(i)
        }
        
        viewControllers = controllers.map({ viewController -> UIViewController in
            return UINavigationController(rootViewController: viewController)
        })
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
