//
//  DrumMainViewController.swift
//  SereyIO
//
//  Created by Panha Uy on 14/6/22.
//  Copyright © 2022 Serey IO. All rights reserved.
//

import UIKit

class DrumMainViewController: BaseTabBarViewController {
    
    private var previousController: UIViewController? = nil
    private var browseDrumsViewController: BrowseDrumsViewController!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.browseDrumsViewController = .init(viewModel: .init(containPostItem: true))
        setUpViews()
    }
    
    override func setUpLocalizedTexts() {
        if let viewControllers = self.viewControllers {
            for i in 0..<viewControllers.count {
                ((viewControllers[i] as? UINavigationController)?.viewControllers.first as? TabBarControllerDelegate)?.configureTabBar(i)
            }
        }
    }
    
    override func notificationReceived(_ notification: Notification) {
        super.notificationReceived(notification)
        
        switch notification.appNotification {
        case .userDidLogin, .userDidLogOut:
            self.configureTabBarController()
        default:
            break
        }
    }
}

// MARK: - Preparations & Tools
extension DrumMainViewController {
    
    enum ControllerType: Int, CaseIterable {
        case home = 0, myFeed, myDrums, people
        
        func prepareViewController() -> UIViewController {
            var viewController: UIViewController? = nil
            switch self {
            case .home:
                viewController = BrowseDrumsViewController(viewModel: .init(containPostItem: true))
            case .myFeed:
                viewController = MyFeedViewController()
            case .myDrums:
                viewController = MyDrumsViewController()
            case .people:
                viewController = DrumsPeopleViewController()
            }
            
            return viewController ?? UIViewController()
        }
    }
    
    func setUpViews() {
        configureTabBarController()
        self.delegate = self
    }
    
    func configureTabBarController() {
        var controllers: [UIViewController] = [browseDrumsViewController]
        
        if AuthData.shared.isUserLoggedIn {
            controllers.append(ControllerType.myFeed.prepareViewController())
            controllers.append(ControllerType.myDrums.prepareViewController())
            controllers.append(ControllerType.people.prepareViewController())
        }
        
        for i in 0..<controllers.count {
            (controllers[i] as? TabBarControllerDelegate)?.configureTabBar(i)
        }
        
        viewControllers = controllers.map({ viewController -> UIViewController in
            return CloseableNavigationController(rootViewController: viewController)
        })
        
        self.tabBar.isHidden = (self.viewControllers?.count ?? 0) <= 1
    }
}

// MARK: - UITabBarControllerDelegate
extension DrumMainViewController: UITabBarControllerDelegate {

    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        if let navigationViewController = viewController as? UINavigationController {
            if let viewController = navigationViewController.viewControllers.first {
                self.previousController = viewController
            }
        }
    }
}
