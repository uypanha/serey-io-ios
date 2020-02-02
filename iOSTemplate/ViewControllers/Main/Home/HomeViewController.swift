//
//  HomeViewController.swift
//  iOSTemplate
//
//  Created by Phanha Uy on 2/2/20.
//  Copyright © 2020 Phanha Uy. All rights reserved.
//

import UIKit

class HomeViewController: BaseViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
}

// MARK: - TabBarControllerDelegate
extension HomeViewController: TabBarControllerDelegate {
    
    func configureTabBar(_ tag: Int) {
        self.tabBarItem = UITabBarItem(title: "Home", image: R.image.tabHome(), selectedImage: R.image.tabHomeSelected())
        self.tabBarItem?.tag = tag
    }
}
