//
//  ConfirmDelegatePowerViewController.swift
//  SereyIO
//
//  Created by Panha Uy on 11/4/21.
//  Copyright © 2021 Serey IO. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift
import RxBinding
import Then

class ConfirmDelegatePowerViewController: BaseViewController, BottomSheetProtocol {
    
    var preferredBottomSheetContentSize: CGSize? {
        let preferedSize = CGSize(width: self.view.frame.width, height: 246 + 32 + 22)
        return preferedSize
    }
    
    lazy var totalAmountLabel: UILabel = {
        return .createLabel(14, weight: .regular, textColor: .darkGray)
    }()
    
    lazy var amountLabel: UILabel = {
        return .createLabel(20, weight: .bold, textColor: .color(.primary))
    }()
    
    lazy var fromLabel: UILabel = {
        return .createLabel(14, weight: .regular, textColor: .darkGray)
    }()
    
    lazy var fromUsernameLabel: UILabel  = {
        return .createLabel(16, weight: .semibold, textColor: .black)
    }()
    
    lazy var toLabel: UILabel  = {
        return .createLabel(14, weight: .regular, textColor: .darkGray)
    }()
    
    lazy var toUsernameLabel: UILabel = {
        return .createLabel(16, weight: .semibold, textColor: .black)
    }()
    
    lazy var delegateButton: LoadingButton = {
        return .init().then {
            $0.setTitleColor(.white, for: .normal)
            $0.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
            $0.snp.makeConstraints { make in
                make.height.equalTo(46)
            }
        }
    }()
    
    var viewModel: ConfirmDelegatePowerViewModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpViews()
        setUpRxObservers()
    }
    
    override func setUpLocalizedTexts() {
        super.setUpLocalizedTexts()
        
        self.totalAmountLabel.text = "Total amount"
        self.fromLabel.text = "From"
        self.toLabel.text = "To"
        self.delegateButton.setTitle("Delegate", for: .normal)
    }
}

// MARK: - Preparations & Tools
extension ConfirmDelegatePowerViewController {
    
    func setUpViews() {
        let mainView = self.prepareViews()
        self.view.addSubview(mainView)
        mainView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        self.delegateButton.primaryStyle()
    }
}

// MARK: - SetUp RxObservers
extension ConfirmDelegatePowerViewController {
    
    func setUpRxObservers() {
        setUpControlObservers()
        setUpContentChangedObservers()
        setUpViewToPresentObservers()
    }
    
    func setUpContentChangedObservers() {
        self.disposeBag ~ [
            self.viewModel.amount ~> self.amountLabel.rx.text,
            self.viewModel.fromAccount ~> self.fromUsernameLabel.rx.text,
            self.viewModel.toAccount ~> self.toUsernameLabel.rx.text
        ]
    }
    
    func setUpControlObservers() {
        self.delegateButton.rx.tap.asObservable()
            .map { ConfirmDelegatePowerViewModel.Action.confirmPressed }
            ~> self.viewModel.didActionSubject
            ~ self.disposeBag
    }
    
    func setUpViewToPresentObservers() {
        self.viewModel.shouldPresent.asObservable()
            .subscribe(onNext: { [weak self] viewToPresent in
                switch viewToPresent {
                case .dismiss:
                    self?.dismiss(animated: true, completion: nil)
                }
            }) ~ self.disposeBag
    }
}
