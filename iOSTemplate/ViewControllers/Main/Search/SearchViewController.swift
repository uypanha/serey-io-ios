//
//  SearchViewController.swift
//  iOSTemplate
//
//  Created by Phanha Uy on 2/2/20.
//  Copyright © 2020 Phanha Uy. All rights reserved.
//

import UIKit

class SearchViewController: BaseViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
}

// MARK: - TabBarControllerDelegate
extension SearchViewController: TabBarControllerDelegate {
    
    func configureTabBar(_ tag: Int) {
        self.tabBarItem = UITabBarItem(title: "Search", image: R.image.tabSearch(), selectedImage: R.image.tabSearchSelected())
        self.tabBarItem?.tag = tag
    }
}
