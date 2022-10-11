//
//  DrumsPeopleViewController.swift
//  SereyIO
//
//  Created by Panha Uy on 16/6/22.
//  Copyright © 2022 Serey IO. All rights reserved.
//

import UIKit

class DrumsPeopleViewController: BaseViewController {

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

extension DrumsPeopleViewController: TabBarControllerDelegate {
    
    func configureTabBar(_ tag: Int) {
        self.tabBarItem = .init(title: "People", image: R.image.tabPeople(), selectedImage: R.image.tabPeople())
    }
}
