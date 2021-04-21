//
//  ConfirmPowerUpViewController.swift
//  SereyIO
//
//  Created by Panha Uy on 8/30/20.
//  Copyright © 2020 Serey IO. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift
import RxBinding

class ConfirmPowerUpViewController: BaseViewController, BottomSheetProtocol {
    
    var preferredBottomSheetContentSize: CGSize? {
        let preferedSize = CGSize(width: self.view.frame.width, height: 246 + 32 + 22)
        return preferedSize
    }
    
    @IBOutlet weak var totalAmountLabel: UILabel!
    @IBOutlet weak var amountLabel: UILabel!
    @IBOutlet weak var fromLabel: UILabel!
    @IBOutlet weak var fromUsernameLabel: UILabel!
    @IBOutlet weak var toLabel: UILabel!
    @IBOutlet weak var toUsernameLabel: UILabel!
    @IBOutlet weak var powerUpButton: LoadingButton!
    
    var viewModel: ConfirmPowerViewModel!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setUpViews()
        setUpRxObservers()
    }
}

// MARK: - Preparations & Tools
extension ConfirmPowerUpViewController {
    
    func setUpViews() {
        self.amountLabel.textColor = ColorName.primary.color
        self.powerUpButton.primaryStyle()
    }
}

// MARK: - SetUp RxObservers
extension ConfirmPowerUpViewController {
    
    func setUpRxObservers() {
        setUpContentChangedObservers()
        setUpViewToPresentObservers()
    }
    
    func setUpContentChangedObservers() {
        self.disposeBag ~ [
            self.viewModel.amount ~> self.amountLabel.rx.text,
            self.viewModel.fromAccount ~> self.fromUsernameLabel.rx.text,
            self.viewModel.toAccount ~> self.toUsernameLabel.rx.text
        ]
        
        self.powerUpButton.rx.tap.asObservable()
            .map { ConfirmPowerViewModel.Action.confirmPressed }
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
