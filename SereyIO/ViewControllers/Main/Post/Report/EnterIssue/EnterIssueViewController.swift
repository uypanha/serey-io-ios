//
//  EnterIssueViewController.swift
//  SereyIO
//
//  Created by Mäd on 01/02/2022.
//  Copyright © 2022 Serey IO. All rights reserved.
//

import UIKit

class EnterIssueViewController: BaseViewController {
    
    lazy var titleLabel: UILabel = {
        return .createLabel(22, weight: .medium, textColor: .black)
    }()
    
    override func loadView() {
        self.view = self.prepareViews()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func setUpLocalizedTexts() {
        super.setUpLocalizedTexts()
        
        self.titleLabel.text = "Please enter your issue"
        self.title = "Report"
    }
}
