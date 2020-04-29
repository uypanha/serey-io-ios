//
//  NotificationViewController.swift
//  SereyIO
//
//  Created by Phanha Uy on 2/2/20.
//  Copyright © 2020 Phanha Uy. All rights reserved.
//

import UIKit

class NotificationViewController: BaseViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
}

// MARK: - TabBarControllerDelegate
extension NotificationViewController: TabBarControllerDelegate {
    
    func configureTabBar(_ tag: Int) {
        self.tabBarItem = UITabBarItem(title: R.string.notifications.notifications.localized(), image: R.image.tabNotification(), selectedImage: R.image.tabNotificationSelected())
        self.tabBarItem?.tag = tag
    }
}
