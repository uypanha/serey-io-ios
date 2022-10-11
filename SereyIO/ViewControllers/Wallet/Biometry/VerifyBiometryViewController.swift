//
//  VerifyBiometryViewController.swift
//  SereyIO
//
//  Created by Panha Uy on 10/17/20.
//  Copyright © 2020 Serey IO. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift
import RxBinding

class VerifyBiometryViewController: BaseViewController, AlertDialogController {
    
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var scanTitleLabel: UILabel!
    
    var viewModel: VerifyBiometryViewModel!
    var isAuthenticating: Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setUpViews()
        setUpRxObservers()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if !isAuthenticating {
            self.viewModel.verify()
            self.isAuthenticating = true
        }
    }
}

// MARK: - Preparations & Tools
extension VerifyBiometryViewController {
    
    func setUpViews() {
    }
}


// MARK: - SetUp RxObservers
extension VerifyBiometryViewController {
    
    func setUpRxObservers() {
        setUpContentChangedObservers()
        setUpViewToPresentObservers()
    }
    
    func setUpContentChangedObservers() {
        self.disposeBag ~ [
            self.viewModel.iconImage ~> self.iconImageView.rx.image,
            self.viewModel.titleText ~> self.scanTitleLabel.rx.text
        ]
    }
    
    func setUpViewToPresentObservers() {
        self.viewModel.shouldPresent.asObservable()
            .subscribe(onNext: { [weak self] viewToPresent in
                switch viewToPresent {
                case .walletController:
                    SereyWallet.shared?.rootViewController.switchToMainScreen()
                case .dismiss:
                    self?.dismiss(animated: true, completion: nil)
                case .alertDialogController(let alertDialogModel):
                    self?.showDialog(alertDialogModel)
                }
            }) ~ self.disposeBag
    }
}
