//
//  PowerUpViewController.swift
//  SereyIO
//
//  Created by Panha Uy on 8/25/20.
//  Copyright © 2020 Phanha Uy. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift
import RxBinding
import MaterialComponents

class PowerUpViewController: BaseViewController, KeyboardController {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var contentView: UIView!
    
    @IBOutlet weak var accountTextField: MDCTextField!
    @IBOutlet weak var amountTextField: MDCTextField!
    
    @IBOutlet weak var powerUpButton: LoadingButton!
    
    var accountFieldController: MDCTextInputControllerOutlined?
    var amountFieldController: MDCTextInputControllerOutlined?
    
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
        
        self.titleLabel.text = "Power Up"
    }
}

// MARK: - Preparations & Tools
extension PowerUpViewController {
    
    func setUpViews() {
        self.headerView.backgroundColor = ColorName.primary.color
        
        self.accountFieldController = self.accountTextField.primaryController()
        self.amountFieldController = self.amountTextField.primaryController()
        
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
        self.viewModel.accountTextFieldViewModel.bind(with: self.accountTextField, controller: self.accountFieldController)
        self.viewModel.amountTextFieldViewModel.bind(with: self.amountTextField, controller: self.amountFieldController)
        
//        self.viewModel.isTransferEnabled ~> self.transferButton.rx.isEnabled ~ self.disposeBag
//        self.viewModel.isUsernameEditable ~> self.accountTextField.rx.isEnabled ~ self.disposeBag
    }
    
    func setUpControlObserves() {
//        self.btnPowerUp.rx.tap.asObservable()
//            .filter { !self.transferButton.isLoading }
//            .map { TransferCoinViewModel.Action.transferPressed }
//            ~> self.viewModel.didActionSubject
//            ~ self.disposeBag
    }
    
    func setUpViewToPresentObservers() {
//        self.viewModel.shouldPresent.asObservable()
//            .subscribe(onNext: { [weak self] viewToPresent in
//                switch viewToPresent {
//                case .loading(let loading):
//                    self?.transferButton.isLoading = loading
//                    self?.amountTextField.isEnabled = !loading
//                    self?.memoTextField.isEnabled = !loading
//                case .dismiss:
//                    self?.navigationController?.popViewController(animated: true)
//                case .showAlertDialogController(let alertDialogModel):
//                    self?.showDialog(alertDialogModel)
//                case .confirmTransferController(let confirmTransferViewModel):
//                    if let confirmTransferController = R.storyboard.transfer.confirmTransferViewController() {
//                        confirmTransferController.viewModel = confirmTransferViewModel
//                        let bottomSheet = BottomSheetViewController(contentViewController: confirmTransferController)
//                        self?.present(bottomSheet, animated: true, completion: nil)
//                    }
//                }
//            }) ~ self.disposeBag
    }
    
    func setUpShouldPresentErrorObservers() {
//        self.viewModel.shouldPresentError.asObservable()
//            .subscribe(onNext: { [weak self] error in
//                self?.showDialogError(error)
//            }) ~ self.disposeBag
    }
}
