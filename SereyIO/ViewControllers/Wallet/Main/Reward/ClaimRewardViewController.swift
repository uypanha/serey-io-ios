//
//  ClaimRewardViewController.swift
//  SereyIO
//
//  Created by Panha Uy on 9/3/20.
//  Copyright © 2020 Phanha Uy. All rights reserved.
//

import UIKit

class ClaimRewardViewController: BaseViewController, BottomSheetProtocol {
    
    var preferredBottomSheetContentSize: CGSize? {
        let preferedSize = CGSize(width: self.view.frame.width, height: self.containerView.frame.height)
        return preferedSize
    }
    
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var claimButton: LoadingButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        setUpViews()
    }
}

// MARK: - Preparations & Tools
extension ClaimRewardViewController {
    
    func setUpViews() {
        self.claimButton.primaryStyle()
    }
}
