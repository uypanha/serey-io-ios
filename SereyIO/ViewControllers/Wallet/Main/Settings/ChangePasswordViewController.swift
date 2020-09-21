//
//  ChangePasswordViewController.swift
//  SereyIO
//
//  Created by Panha Uy on 8/16/20.
//  Copyright © 2020 Phanha Uy. All rights reserved.
//

import UIKit
import MaterialComponents

class ChangePasswordViewController: BaseViewController {

    @IBOutlet weak var changePasswordLabel: UILabel!
    @IBOutlet weak var currentPasswordField: MDCPasswordTextField!
    @IBOutlet weak var newPasswordField: MDCPasswordTextField!
    @IBOutlet weak var confirmNewPasswordField: MDCPasswordTextField!
    @IBOutlet weak var changeButton: LoadingButton!
    
    var currentPWDController: MDCTextInputControllerOutlined?
    var newPWDController: MDCTextInputControllerOutlined?
    var confirmPWDController: MDCTextInputControllerOutlined?
 
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpViews()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.removeNavigationBarBorder()
    }
}

// MARK: - Preparations & Tools
extension ChangePasswordViewController {
    
    func setUpViews() {
        self.currentPWDController = self.currentPasswordField.primaryController()
        self.newPWDController = self.newPasswordField.primaryController()
        self.confirmPWDController = self.confirmNewPasswordField.primaryController()
        
        self.changeButton.primaryStyle()
    }
}
