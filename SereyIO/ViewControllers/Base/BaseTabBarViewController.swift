//
//  BaseTabBarViewController.swift
//  SereyIO
//
//  Created by Phanha Uy on 2/2/20.
//  Copyright © 2020 Serey IO. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift

protocol TabBarControllerDelegate {
    
    func configureTabBar(_ tag: Int)
}

class BaseTabBarViewController: UITabBarController, NotificationObserver {

    lazy var disposeBag: DisposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        overrideBackItem()
        registerForNotifs()
    }
    
    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        setUpLocalizedTexts()
    }
    
    open func setUpLocalizedTexts() {}
    
    open func notificationReceived(_ notification: Notification) {
        switch notification.appNotification {
        case .languageChanged:
            setUpLocalizedTexts()
        default:
            break
        }
    }
    
    deinit {
        unregisterFromNotifs()
        #if DEBUG
        print("\(type(of: self).className) ====> DeInit")
        #endif
    }
}
