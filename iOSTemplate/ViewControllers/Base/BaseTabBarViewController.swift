//
//  BaseTabBarViewController.swift
//  iOSTemplate
//
//  Created by Phanha Uy on 2/2/20.
//  Copyright © 2020 Phanha Uy. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift

protocol TabBarControllerDelegate {
    
    func configureTabBar(_ tag: Int)
}

class BaseTabBarViewController: UITabBarController {

    lazy var disposeBag: DisposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        overrideBackItem()
    }
    
    deinit {
        #if DEBUG
        print("\(type(of: self).className) ====> DeInit")
        #endif
    }
}
