//
//  DrumRootViewController.swift
//  SereyIO
//
//  Created by Panha Uy on 14/6/22.
//  Copyright © 2022 Serey IO. All rights reserved.
//

import UIKit

class DrumRootViewController: BaseRootViewController {
    
    var deeplink: DeeplinkType? {
        didSet {
//            handleDeeplink()
        }
    }
    
    init() {
        super.init(DrumMainViewController())
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = .clear
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
