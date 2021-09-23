//
//  ActiveBiometryViewController.swift
//  SereyIO
//
//  Created by Panha Uy on 6/16/20.
//  Copyright © 2020 Serey IO. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift
import RxBinding

class ActiveBiometryViewController: BaseViewController, AlertDialogController {

    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var enableButton: UIButton!
    
    var viewModel: ActiveBiometryViewModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setUpViews()
        setUpRxObservers()
    }
    
    override func setUpLocalizedTexts() {
        super.setUpLocalizedTexts()
        
        self.enableButton.setTitle("Enable", for: .normal)
    }
}

// MARK: - Preparations & Tools
extension ActiveBiometryViewController {
    
    func setUpViews() {
        enableButton.primaryStyle()
    }
}

// MARK: - SetUp RxObservers
extension ActiveBiometryViewController {
    
    func setUpRxObservers() {
        setUpContentChangedObservers()
        setUpViewToPresentObservers()
    }
    
    func setUpContentChangedObservers() {
        self.disposeBag ~ [
            self.viewModel.iconImage ~> self.iconImageView.rx.image,
            self.viewModel.titleText ~> self.titleLabel.rx.text,
            self.viewModel.descriptionText ~> self.descriptionLabel.rx.text,
            self.enableButton.rx.tap.map { ActiveBiometryViewModel.Action.enablePressed } ~> self.viewModel.didActionSubject
        ]
    }
    
    func setUpViewToPresentObservers() {
        self.viewModel.shouldPresent.asObservable()
            .subscribe(onNext: { [weak self] viewToPresent in
                switch viewToPresent {
                case .showAlertDialogController(let alertDialogModel):
                    self?.showDialog(alertDialogModel)
                case .openUrl(let url):
                    if UIApplication.shared.canOpenURL(url) {
                        UIApplication.shared.open(url)
                    }
                case .dismiss:
                    self?.dismiss(animated: true, completion: nil)
                case .walletController:
                    SereyWallet.shared?.rootViewController.switchToMainScreen()
                }
            }) ~ self.disposeBag
    }
}
