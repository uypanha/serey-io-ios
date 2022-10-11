//
//  ActivateGoogleOTP2ViewController.swift
//  SereyIO
//
//  Created by Panha Uy on 10/12/20.
//  Copyright © 2020 Serey IO. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift
import RxBinding

class ActivateGoogleOTP2ViewController: BaseViewController, AlertDialogController {

    @IBOutlet weak var scanLabel: UILabel!
    @IBOutlet weak var otpMessageLabel: UILabel!
    @IBOutlet weak var qrImageView: UIImageView!
    @IBOutlet weak var checkbox: CheckBox!
    @IBOutlet weak var activateButton: UIButton!
    
    var viewModel: ActivateGoogleOTPViewModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setUpViews()
        setUpRxObservers()
    }
    
    @IBAction func didChecked(_ sender: CheckBox) {
        self.viewModel.didAction(with: .agreementChecked(checked: sender.isChecked))
    }
}

// MARK: - Preparations & Tools
extension ActivateGoogleOTP2ViewController {
    
    func setUpViews() {
        self.checkbox.borderStyle = .roundedSquare(radius: 6)
        self.activateButton.primaryStyle()
        self.activateButton.makeMeCircular()
    }
}

// MARK: - SetUp RxObservers
extension ActivateGoogleOTP2ViewController {
    
    func setUpRxObservers() {
        setUpContentChangedObservers()
        setUpControlObservers()
        setUpShouldPresentObservers()
    }
    
    func setUpContentChangedObservers() {
        self.disposeBag ~ [
            self.viewModel.qrImage ~> self.qrImageView.rx.image,
            self.viewModel.isActivateEnabled ~> self.activateButton.rx.isEnabled
        ]
    }
    
    func setUpControlObservers() {
        self.activateButton.rx.tap.asObservable()
            .map { ActivateGoogleOTPViewModel.Action.activatePressed }
            ~> self.viewModel.didActionSubject
            ~ self.disposeBag
    }
    
    func setUpShouldPresentObservers() {
        self.viewModel.shouldPresent.asObservable()
            .subscribe(onNext: { [weak self] viewToPresent in
                switch viewToPresent {
                case .verifyGoogleOTPController(let verifyGoogleOTPViewModel):
                    if let verifyGoogleOTPController = R.storyboard.googleOTP.verifyGoogleOTPViewController() {
                        verifyGoogleOTPController.viewModel = verifyGoogleOTPViewModel
                        self?.show(verifyGoogleOTPController, sender: nil)
                    }
                case .dismiss:
                    self?.dismiss(animated: true, completion: nil)
                case .showAlertDialog(let alertDialogModel):
                    self?.showDialog(alertDialogModel)
                case .walletController:
                    SereyWallet.shared?.rootViewController.switchToMainScreen()
                }
            }) ~ self.disposeBag
    }
}
