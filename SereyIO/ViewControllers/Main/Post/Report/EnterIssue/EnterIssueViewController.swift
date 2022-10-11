//
//  EnterIssueViewController.swift
//  SereyIO
//
//  Created by Mäd on 01/02/2022.
//  Copyright © 2022 Serey IO. All rights reserved.
//

import UIKit
import MaterialComponents
import SnapKit
import Then
import RxCocoa
import RxSwift
import RxBinding

class EnterIssueViewController: BaseViewController, KeyboardController, LoadingIndicatorController {
    
    lazy var titleLabel: UILabel = {
        return .createLabel(22, weight: .medium, textColor: .black)
    }()
    
    lazy var textField: MDCOutlinedTextField = {
        return .init().then {
            $0.primaryStyle()
        }
    }()
    
    lazy var reportButton: UIButton = {
        return .createButton(with: 17, weight: .medium).then {
            $0.setTitleColor(.white, for: .normal)
            $0.snp.makeConstraints { make in
                make.height.equalTo(UIButton.DEFAULT_BUTTON_HEIGHT)
            }
        }
    }()
    
    var viewModel: EnterIssueViewModel!
    
    override func loadView() {
        self.view = self.prepareViews()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setUpRxObservers()
    }
    
    override func setUpLocalizedTexts() {
        super.setUpLocalizedTexts()
        
        self.titleLabel.text = "Please enter your issue"
        self.title = "Report"
        self.reportButton.setTitle("Report", for: .normal)
        self.reportButton.primaryStyle()
    }
}

// MARK: - SetUp RxObservers
extension EnterIssueViewController {
    
    func setUpRxObservers() {
        setUpControlObservers()
        setUpContentChangedObservers()
        setUpViewToPresentObservers()
        setUpTabSelfToDismissKeyboard()?.disposed(by: self.disposeBag)
    }
    
    func setUpControlObservers() {
        self.reportButton.rx.tap.asObservable()
            .map { EnterIssueViewModel.Action.reportPressed }
            ~> self.viewModel.didActionSubject
            ~ self.disposeBag
    }
    
    func setUpContentChangedObservers() {
        self.viewModel.issueTextFieldViewModel.bind(withMDC: self.textField)
    }
    
    func setUpViewToPresentObservers() {
        self.viewModel.shouldPresent.asObservable()
            .subscribe(onNext: { [weak self] viewToPresent in
                switch viewToPresent {
                case .confirmDialogController(let viewModel, let dismissable):
                    let confirmDialogViewController = ConfirmDialogViewController(viewModel)
                    let bottomSheet = BottomSheetViewController(contentViewController: confirmDialogViewController)
                    bottomSheet.dismissOnBackgroundTap = dismissable
                    self?.present(bottomSheet, animated: true, completion: nil)
                case .loading(let loading):
                    loading ? self?.showLoading("Loading...") : self?.dismissLoading()
                case .dismiss:
                    self?.dismiss(animated: true, completion: nil)
                }
            }) ~ self.disposeBag
    }
}
