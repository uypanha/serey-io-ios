//
//  PowerDownViewController.swift
//  SereyIO
//
//  Created by Panha Uy on 8/27/20.
//  Copyright © 2020 Serey IO. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift
import RxBinding
import MaterialComponents

class PowerDownViewController: BaseViewController, KeyboardController, AlertDialogController {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var powerDownMessageLabel: UILabel!
    
    @IBOutlet weak var accountTextField: MDCOutlinedTextField!
    @IBOutlet weak var amountTextField: MDCOutlinedTextField!
    
    @IBOutlet weak var powerDownButton: LoadingButton!
    
    var viewModel: PowerDownViewModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setUpViews()
        setUpRxObservers()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.setNavigationBarColor(.color(.primary), tintColor: .white)
        self.navigationController?.removeNavigationBarBorder()
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
        self.headerView.backgroundColor = .color(.primary)
        
        self.accountTextField.primaryStyle()
        self.amountTextField.primaryStyle()
        self.accountTextField.isEnabled = false
        
        self.amountTextField.leftView = UIImageView(image: R.image.amountIcon()).then { $0.tintColor = .gray }
        self.amountTextField.leftViewMode = .always
        self.accountTextField.leftView = UIImageView(image: R.image.accountIcon()).then { $0.tintColor = .gray }
        self.accountTextField.leftViewMode = .always
        
        self.powerDownButton.primaryStyle()
    }
}

// MARK: - SetUp RxObservers
extension PowerDownViewController {
    
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
        
        self.viewModel.isPowerDownEnabled ~> self.powerDownButton.rx.isEnabled ~ self.disposeBag
    }
    
    func setUpControlObserves() {
        self.powerDownButton.rx.tap.asObservable()
            .filter { !self.powerDownButton.isLoading }
            .map { PowerDownViewModel.Action.powerDownPressed }
            ~> self.viewModel.didActionSubject
            ~ self.disposeBag
    }
    
    func setUpViewToPresentObservers() {
        self.viewModel.shouldPresent.asObservable()
            .subscribe(onNext: { [weak self] viewToPresent in
                switch viewToPresent {
                case .loading(let loading):
                    self?.powerDownButton.isLoading = loading
                    self?.accountTextField.isEnabled = !loading
                    self?.amountTextField.isEnabled = !loading
                case .confirmPowerDownController(let confirmPowerViewModel):
                    if let confirmPowerDownController = R.storyboard.power.confirmPowerDownViewController() {
                        confirmPowerDownController.viewModel = confirmPowerViewModel
                        let bottomSheet = BottomSheetViewController(contentViewController: confirmPowerDownController)
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
