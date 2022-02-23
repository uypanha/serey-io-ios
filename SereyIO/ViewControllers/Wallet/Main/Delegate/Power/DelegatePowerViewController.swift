//
//  DelegatePowerViewController.swift
//  SereyIO
//
//  Created by Panha Uy on 11/3/21.
//  Copyright © 2021 Serey IO. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift
import RxBinding
import MaterialComponents

class DelegatePowerViewController: BaseViewController, KeyboardController, AlertDialogController {
    
    lazy var headerView: TransactionHeaderView = {
        return .init()
    }()
    
    lazy var contentView: UIView = {
        return .init().then {
            $0.backgroundColor = .white
        }
    }()
    
    var accountTextField: MDCOutlinedTextField!
    var amountTextField: MDCOutlinedTextField!
    var delegateButton: LoadingButton!
    
    var viewModel: DelegatePowerViewModel!
    
    override func loadView() {
        self.view = self.prepareViews()
    }
    
    override open func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        overrideBackItem()
        registerForNotifs()
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

// MARK: - SetUp RxObservers
extension DelegatePowerViewController {
    
    func setUpRxObservers() {
        setUpControlObservers()
        setUpContentChangedObservers()
        setUpViewToPresentObservers()
        setUpTabSelfToDismissKeyboard()?.disposed(by: self.disposeBag)
    }
    
    func setUpControlObservers() {
        self.delegateButton.rx.tap.asObservable()
            .map { DelegatePowerViewModel.Action.delegatePressed }
            ~> self.viewModel.didActionSubject
            ~ self.disposeBag
    }
    
    func setUpContentChangedObservers() {
        self.viewModel.accountTextFieldViewModel.bind(withMDC: self.accountTextField)
        self.viewModel.amountTextFieldViewModel.bind(withMDC: self.amountTextField)
        self.viewModel.titleText ~> self.headerView.titleLabel.rx.text ~ self.disposeBag
        self.viewModel.isDelegateEnabled ~> self.delegateButton.rx.isEnabled ~ self.disposeBag
        self.viewModel.isAmountHidden ~> self.amountTextField.rx.isHidden ~ self.disposeBag
        self.viewModel.submitButtonTitle ~> self.delegateButton.rx.title(for: .normal) ~ self.disposeBag
    }
    
    func setUpViewToPresentObservers() {
        self.viewModel.shouldPresent.asObservable()
            .subscribe(onNext: { [unowned self] viewToPresent in
                switch viewToPresent {
                case .dismiss:
                    self.navigationController?.popViewController(animated: true)
                case .loading(let loading):
                    self.delegateButton.isLoading = loading
                    self.accountTextField.isEnabled = !loading
                    self.amountTextField.isEnabled = !loading
                case .showAlertDialogController(let alertDialogModel):
                    self.showDialog(alertDialogModel)
                case .confirmDelegatePowerController(let confirmDelegatePowerViewModel):
                    let confirmDelegatePowerViewController = ConfirmDelegatePowerViewController()
                    confirmDelegatePowerViewController.viewModel = confirmDelegatePowerViewModel
                    let bottomSheet = BottomSheetViewController(contentViewController: confirmDelegatePowerViewController)
                    self.present(bottomSheet, animated: true, completion: nil)
                case .confirmCancelDelegateController(let viewModel):
                    let confirmCancelDelegateViewController = ConfirmDialogViewController(viewModel)
                    let bottomSheet = BottomSheetViewController(contentViewController: confirmCancelDelegateViewController)
                    self.present(bottomSheet, animated: true, completion: nil)
                }
            }) ~ self.disposeBag
    }
}
