//
//  TransferViewController.swift
//  SereyIO
//
//  Created by Panha Uy on 8/3/20.
//  Copyright © 2020 Serey IO. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift
import RxBinding
import MaterialComponents

class TransferViewController: BaseViewController, KeyboardController, LoadingIndicatorController, AlertDialogController {
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var accountTextField: MDCOutlinedTextField!
    @IBOutlet weak var amountTextField: MDCOutlinedTextField!
    @IBOutlet weak var memoTextField: MDCOutlinedTextField!
    @IBOutlet weak var transferButton: LoadingButton!
    
    var viewModel: TransferCoinViewModel!
    
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
}

// MARK: - Preparations & Tools
extension TransferViewController {
    
    func setUpViews() {
        self.headerView.backgroundColor = .color(.primary)
        
        self.accountTextField.primaryStyle()
        self.amountTextField.primaryStyle()
        self.memoTextField.primaryStyle()
        
        self.amountTextField.leftView = UIImageView(image: R.image.amountIcon()).then { $0.tintColor = .gray }
        self.amountTextField.leftViewMode = .always
        self.accountTextField.leftView = UIImageView(image: R.image.accountIcon()).then { $0.tintColor = .gray }
        self.accountTextField.leftViewMode = .always
        
        self.transferButton.primaryStyle()
    }
}

// MARK: - SetUp RxObservers
extension TransferViewController {
    
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
        self.viewModel.memoTextFieldViewModel.bind(withMDC: self.memoTextField)
        
        self.viewModel.isTransferEnabled ~> self.transferButton.rx.isEnabled ~ self.disposeBag
        self.viewModel.isUsernameEditable ~> self.accountTextField.rx.isEnabled ~ self.disposeBag
    }
    
    func setUpControlObserves() {
        self.transferButton.rx.tap.asObservable()
            .filter { !self.transferButton.isLoading }
            .map { TransferCoinViewModel.Action.transferPressed }
            ~> self.viewModel.didActionSubject
            ~ self.disposeBag
    }
    
    func setUpViewToPresentObservers() {
        self.viewModel.shouldPresent.asObservable()
            .subscribe(onNext: { [weak self] viewToPresent in
                switch viewToPresent {
                case .loading(let loading):
                    self?.transferButton.isLoading = loading
                    self?.amountTextField.isEnabled = !loading
                    self?.memoTextField.isEnabled = !loading
                case .dismiss:
                    self?.navigationController?.popViewController(animated: true)
                case .showAlertDialogController(let alertDialogModel):
                    self?.showDialog(alertDialogModel)
                case .confirmTransferController(let confirmTransferViewModel):
                    if let confirmTransferController = R.storyboard.transfer.confirmTransferViewController() {
                        confirmTransferController.viewModel = confirmTransferViewModel
                        let bottomSheet = BottomSheetViewController(contentViewController: confirmTransferController)
                        self?.present(bottomSheet, animated: true, completion: nil)
                    }
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
