//
//  BaseTableViewController.swift
//  iOSTemplate
//
//  Created by Phanha Uy on 2/6/20.
//  Copyright © 2020 Phanha Uy. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift

open class BaseTableViewController: UITableViewController, LocalizeProtocol, NotificationObserver {
    
    lazy var disposeBag: DisposeBag = DisposeBag()

    override open func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        registerForNotifs()
    }
    
    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
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
