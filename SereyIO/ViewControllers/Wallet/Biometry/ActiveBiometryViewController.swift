//
//  ActiveBiometryViewController.swift
//  SereyIO
//
//  Created by Panha Uy on 6/16/20.
//  Copyright © 2020 Phanha Uy. All rights reserved.
//

import UIKit

class ActiveBiometryViewController: BaseViewController {

    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var enableButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setUpViews()
    }
}

// MARK: - Preparations & Tools
extension ActiveBiometryViewController {
    
    func setUpViews() {
        enableButton.primaryStyle()
    }
}
