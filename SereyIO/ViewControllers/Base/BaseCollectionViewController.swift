//
//  BaseCollectionViewController.swift
//  SereyIO
//
//  Created by Mäd on 13/12/2021.
//  Copyright © 2021 Serey IO. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift

class BaseCollectionViewController: UICollectionViewController, LocalizeProtocol, NotificationObserver {
    
    lazy var disposeBag: DisposeBag = DisposeBag()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Do any additional setup after loading the view.
        overrideBackItem()
        setUpLocalizedTexts()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.collectionView.dataSource = nil
        registerForNotifs()
    }
    
    open func setUpLocalizedTexts() {}
    
    func notificationReceived(_ notification: Notification) {
        guard let appNotif = notification.appNotification else { return }
        switch appNotif {
        case .languageChanged:
            setUpLocalizedTexts()
        default:
            break
        }
    }
    
    deinit {
        unregisterFromNotifs()
        print("\(type(of: self).className) ====> DeInit")
    }
}
