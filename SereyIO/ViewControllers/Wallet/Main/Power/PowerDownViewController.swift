//
//  PowerDownViewController.swift
//  SereyIO
//
//  Created by Panha Uy on 8/27/20.
//  Copyright © 2020 Phanha Uy. All rights reserved.
//

import UIKit
import MaterialComponents

class PowerDownViewController: BaseViewController {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var powerDownMessageLabel: UILabel!
    
    @IBOutlet weak var accountTextField: MDCTextField!
    @IBOutlet weak var amountTextField: MDCTextField!
    
    @IBOutlet weak var powerDownButton: LoadingButton!
    
    var accountFieldController: MDCTextInputControllerOutlined?
    var amountFieldController: MDCTextInputControllerOutlined?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setUpViews()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.removeNavigationBarBorder()
        self.navigationController?.setNavigationBarColor(ColorName.primary.color, tintColor: .white)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        self.contentView.roundCorners(corners: [.topLeft, .topRight], radius: 12)
    }
    
    override func setUpLocalizedTexts() {
        super.setUpLocalizedTexts()
        
        self.titleLabel.text = R.string.transfer.powerDown.localized()
        self.powerDownButton.setTitle(R.string.transfer.powerDown.localized(), for: .normal)
    }
}

// MARK: - Preparations & Tools
extension PowerDownViewController {
    
    func setUpViews() {
        self.headerView.backgroundColor = ColorName.primary.color
        
        self.accountFieldController = self.accountTextField.primaryController()
        self.amountFieldController = self.amountTextField.primaryController()
        
        self.amountTextField.leftView = UIImageView(image: R.image.amountIcon()).then { $0.tintColor = .gray }
        self.amountTextField.leftViewMode = .always
        self.accountTextField.leftView = UIImageView(image: R.image.accountIcon()).then { $0.tintColor = .gray }
        self.accountTextField.leftViewMode = .always
        
        self.powerDownButton.primaryStyle()
    }
}
