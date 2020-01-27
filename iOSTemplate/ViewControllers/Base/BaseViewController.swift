//
//  BaseViewController.swift
//  iOSTemplate
//
//  Created by Phanha Uy on 9/15/19.
//  Copyright © 2019 Phanha Uy. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift

open class BaseViewController: UIViewController, LocalizeProtocol {
    
    lazy var disposeBag: DisposeBag = DisposeBag()
    
    override open func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        setUpLocalizedTexts()
    }
    
    open func setUpLocalizedTexts() {}
    
    deinit {
        #if DEBUG
        print("\(type(of: self).className) ====> DeInit")
        #endif
    }
}

protocol LocalizeProtocol {
    
    func setUpLocalizedTexts()
}
