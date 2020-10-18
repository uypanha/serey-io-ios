//
//  VerifyGoogleOTPViewController.swift
//  SereyIO
//
//  Created by Panha Uy on 10/13/20.
//  Copyright © 2020 Phanha Uy. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift
import RxBinding
import PinCodeTextField

class VerifyGoogleOTPViewController: BaseViewController, AlertDialogController {
    
    @IBOutlet weak var verifyAccountLabel: UILabel!
    @IBOutlet weak var enterDigitsLabel: UILabel!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var pinTextFields: PinCodeTextField!
    @IBOutlet weak var confirmOTPButton: UIButton!
    
    var viewModel: VerifyGoogleOTPViewModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setUpViews()
        setUpRxObservers()
    }
}

// MARK: - Preparations & Tools
extension VerifyGoogleOTPViewController {
    
    func setUpViews() {
        self.confirmOTPButton.primaryStyle()
        self.confirmOTPButton.makeMeCircular()
        
        self.pinTextFields.delegate = self
        self.pinTextFields.keyboardType = .numberPad
    }
}

// MARK: - PinCodeTextFieldDelegate
extension VerifyGoogleOTPViewController: PinCodeTextFieldDelegate {
    
    func textFieldValueChanged(_ textField: PinCodeTextField) {
        self.viewModel.pinCodeTextFieldViewModel.value = textField.text
    }
}

// MARK: - SetUp RxObservers
extension VerifyGoogleOTPViewController {
    
    func setUpRxObservers() {
        setUpContentObservers()
        setUpControlObservers()
        setUpViewToPresentObservers()
    }
    
    func setUpContentObservers() {
        self.disposeBag ~ [
            self.viewModel.messageText ~> self.messageLabel.rx.text,
            self.viewModel.verifyButtonTitle ~> self.confirmOTPButton.rx.title(for: .normal),
            self.viewModel.isVerifyEnabled ~> self.confirmOTPButton.rx.isEnabled
        ]
    }
    
    func setUpControlObservers() {
        self.confirmOTPButton.rx.tap.asObservable()
            .map { VerifyGoogleOTPViewModel.Action.confirmPressed }
            ~> self.viewModel.didActionSubject
            ~ self.disposeBag
    }
    
    func setUpViewToPresentObservers() {
        self.viewModel.shouldPresent.asObservable()
            .subscribe(onNext: { [weak self] viewToPresent in
                switch viewToPresent {
                case .dismiss:
                    self?.navigationController?.popViewController(animated: true)
                case .walletController:
                    SereyWallet.shared?.rootViewController.switchToMainScreen()
                case .alertDialogController(let alertDialogModel):
                    self?.showDialog(alertDialogModel)
                }
            }) ~ self.disposeBag
    }
}
