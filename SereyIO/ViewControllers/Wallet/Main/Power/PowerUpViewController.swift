//
//  PowerUpViewController.swift
//  SereyIO
//
//  Created by Panha Uy on 8/25/20.
//  Copyright © 2020 Serey IO. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift
import RxBinding
import MaterialComponents

class PowerUpViewController: BaseViewController, KeyboardController, AlertDialogController {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var contentView: UIView!
    
    @IBOutlet weak var accountTextField: MDCOutlinedTextField!
    @IBOutlet weak var amountTextField: MDCOutlinedTextField!
    
    @IBOutlet weak var upMyselfButton: UIButton!
    @IBOutlet weak var powerUpButton: LoadingButton!
    
    var viewModel: PowerUpViewModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setUpViews()
        setUpRxObservers()
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
        
        self.titleLabel.text = R.string.transfer.powerUp.localized()
        self.powerUpButton.setTitle(R.string.transfer.powerUp.localized(), for: .normal)
    }
}

// MARK: - Preparations & Tools
extension PowerUpViewController {
    
    func setUpViews() {
        self.headerView.backgroundColor = ColorName.primary.color
        
        self.accountTextField.primaryStyle()
        self.amountTextField.primaryStyle()
        
        self.amountTextField.leftView = UIImageView(image: R.image.amountIcon()).then { $0.tintColor = .gray }
        self.amountTextField.leftViewMode = .always
        self.accountTextField.leftView = UIImageView(image: R.image.accountIcon()).then { $0.tintColor = .gray }
        self.accountTextField.leftViewMode = .always
        
        self.powerUpButton.primaryStyle()
    }
}

// MARK: - SetUp RxObservers
extension PowerUpViewController {
    
    func setUpRxObservers() {
        setUpContentChangedObservers()
        setUpControlObserves()
        setUpViewToPresentObservers()
        setUpShouldPresentErrorObservers()
        setUpTabSelfToDismissKeyboard()?.disposed(by: self.disposeBag)
    }
    
    func setUpContentChangedObservers() {
        self.viewModel.accountTextFieldViewModel.bind(withMDC: self.accountTextField)
        self.viewModel.amountTextFieldViewModel.bind(withMDC: self.amountTextField)
        
        self.viewModel.isPowerUpEnabled ~> self.powerUpButton.rx.isEnabled ~ self.disposeBag
    }
    
    func setUpControlObserves() {
        self.upMyselfButton.rx.tap.asObservable()
            .map { PowerUpViewModel.Action.upToMySelfPressed }
            ~> self.viewModel.didActionSubject
            ~ self.disposeBag
        
        self.powerUpButton.rx.tap.asObservable()
            .filter { !self.powerUpButton.isLoading }
            .map { PowerUpViewModel.Action.powerUpPressed }
            ~> self.viewModel.didActionSubject
            ~ self.disposeBag
    }
    
    func setUpViewToPresentObservers() {
        self.viewModel.shouldPresent.asObservable()
            .subscribe(onNext: { [weak self] viewToPresent in
                switch viewToPresent {
                case .loading(let loading):
                    self?.powerUpButton.isLoading = loading
                    self?.accountTextField.isEnabled = !loading
                    self?.amountTextField.isEnabled = !loading
                case .confirmPowerUpController(let confirmPowerViewModel):
                    if let confirmPowerUpController = R.storyboard.power.confirmPowerUpViewController() {
                        confirmPowerUpController.viewModel = confirmPowerViewModel
                        let bottomSheet = BottomSheetViewController(contentViewController: confirmPowerUpController)
                        self?.present(bottomSheet, animated: true, completion: nil)
                    }
                case .dismiss:
                    self?.navigationController?.popViewController(animated: true)
                case .showAlertDialogController(let alertDialogModel):
                    self?.showDialog(alertDialogModel)
                }
            }) ~ self.disposeBag
    }
    
    func setUpShouldPresentErrorObservers() {
        self.viewModel.shouldPresentError.asObservable()
            .subscribe(onNext: { [weak self] error in
                self?.showDialogError(error)
            }) ~ self.disposeBag
    }
}
