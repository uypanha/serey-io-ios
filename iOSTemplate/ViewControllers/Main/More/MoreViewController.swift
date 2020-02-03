//
//  MoreViewController.swift
//  iOSTemplate
//
//  Created by Phanha Uy on 2/2/20.
//  Copyright © 2020 Phanha Uy. All rights reserved.
//

import UIKit

class MoreViewController: BaseViewController {
    
    private lazy var logoBarItem: UIBarButtonItem = {
        let customView = UIImageView()
        customView.image = R.image.logo()
        return UIBarButtonItem(customView: customView)
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        setUpViews()
    }
}

// MARK: - Preparations & Tools
extension MoreViewController {
    
    func setUpViews() {
        self.navigationController?.removeNavigationBarBorder()
        self.navigationItem.leftBarButtonItem = logoBarItem
    }
}

// MARK: - TabBarControllerDelegate
extension MoreViewController: TabBarControllerDelegate {
    
    func configureTabBar(_ tag: Int) {
        self.tabBarItem = UITabBarItem(title: "More", image: R.image.tabMore(), selectedImage: R.image.tabMoreSelected())
        self.tabBarItem?.tag = tag
    }
}
