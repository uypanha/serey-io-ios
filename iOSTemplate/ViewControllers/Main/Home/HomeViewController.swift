//
//  HomeViewController.swift
//  iOSTemplate
//
//  Created by Phanha Uy on 2/2/20.
//  Copyright © 2020 Phanha Uy. All rights reserved.
//

import UIKit
import MaterialComponents

class HomeViewController: BaseViewController {
    
    @IBOutlet weak var tabBar: MDCTabBar!
    @IBOutlet weak var scrollView: UIScrollView!
    
    private lazy var logoBarItem: UIBarButtonItem = {
        let customView = UIImageView()
        customView.image = R.image.logo()
        return UIBarButtonItem(customView: customView)
    }()
    
    private lazy var filterButton: UIBarButtonItem = { [unowned self] in
        return UIBarButtonItem(image: R.image.filterIcon(), style: .plain, target: nil, action: nil)
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setUpViews()
    }
}

// MARK: - Preparations & Tools
extension HomeViewController {
    
    func setUpViews() {
        self.navigationController?.removeNavigationBarBorder()
        self.navigationItem.leftBarButtonItem = logoBarItem
        self.navigationItem.rightBarButtonItem = filterButton
        
        prepareTabBar()
        prepareStoryTabs()
    }
    
    func prepareTabBar() {
        tabBar.tintColor = ColorName.primary.color
        tabBar.setTitleColor(.gray, for: .normal)
        tabBar.setTitleColor(ColorName.primary.color, for: .selected)
        tabBar.selectedItemTitleFont = UIFont.systemFont(ofSize: 14, weight: .medium)
        tabBar.unselectedItemTitleFont = UIFont.systemFont(ofSize: 14, weight: .medium)
        tabBar.displaysUppercaseTitles = false
        tabBar.rippleColor = .clear
        tabBar.enableRippleBehavior = false
        tabBar.inkColor = .clear
        tabBar.itemAppearance = .titles
        tabBar.alignment = .justified
        tabBar.selectionIndicatorTemplate = TabBarIndicator()
        tabBar.bottomDividerColor = .lightGray
    }
    
    func prepareStoryTabs() {
        tabBar.items = [
            UITabBarItem(title: "TRENDING", image: nil, selectedImage: nil),
            UITabBarItem(title: "HOT", image: nil, selectedImage: nil),
            UITabBarItem(title: "NEW", image: nil, selectedImage: nil),
        ]
        tabBar.tintColor = ColorName.primary.color
    }
}

// MARK: - TabBarControllerDelegate
extension HomeViewController: TabBarControllerDelegate {
    
    func configureTabBar(_ tag: Int) {
        self.tabBarItem = UITabBarItem(title: "Home", image: R.image.tabHome(), selectedImage: R.image.tabHomeSelected())
        self.tabBarItem?.tag = tag
    }
}
