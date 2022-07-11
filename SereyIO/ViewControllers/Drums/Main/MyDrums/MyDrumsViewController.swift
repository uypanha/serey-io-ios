//
//  MyDrumsViewController.swift
//  SereyIO
//
//  Created by Panha Uy on 16/6/22.
//  Copyright © 2022 Serey IO. All rights reserved.
//

import UIKit

class MyDrumsViewController: BaseViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.view.backgroundColor = .color("#FAFAFA")
    }
    
    override func notificationReceived(_ notification: Notification) {
        super.notificationReceived(notification)
        
        switch notification.appNotification {
        case .userDidLogin, .userDidLogOut:
            break
        default:
            break
        }
    }
}

extension MyDrumsViewController: TabBarControllerDelegate {
    
    func configureTabBar(_ tag: Int) {
        self.tabBarItem = .init(title: "My Drums", image: R.image.tabMyDrums(), selectedImage: R.image.tabMyDrums())
    }
}
