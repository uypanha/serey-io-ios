//
//  BaseViewController.swift
//  SereyIO
//
//  Created by Phanha Uy on 9/15/19.
//  Copyright © 2020 Serey IO. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift

protocol LocalizeProtocol {
    
    func setUpLocalizedTexts()
}

open class BaseViewController: UIViewController, LocalizeProtocol, NotificationObserver {
    
    lazy var disposeBag: DisposeBag = DisposeBag()
    
    override open func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        overrideBackItem()
        registerForNotifs()
    }
    
    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
        self.navigationController?.setNeedsStatusBarAppearanceUpdate()
        self.setNeedsStatusBarAppearanceUpdate()
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
