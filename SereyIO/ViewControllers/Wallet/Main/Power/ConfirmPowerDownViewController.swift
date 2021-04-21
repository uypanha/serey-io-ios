//
//  ConfirmPowerDownViewController.swift
//  SereyIO
//
//  Created by Panha Uy on 9/3/20.
//  Copyright © 2020 Serey IO. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift
import RxBinding

class ConfirmPowerDownViewController: BaseViewController, BottomSheetProtocol {
    
    var preferredBottomSheetContentSize: CGSize? {
        let preferedSize = CGSize(width: self.view.frame.width, height: 188 + 32 + 22)
        return preferedSize
    }
    
    @IBOutlet weak var totalAmountLabel: UILabel!
    @IBOutlet weak var amountLabel: UILabel!
    @IBOutlet weak var fromLabel: UILabel!
    @IBOutlet weak var fromUsernameLabel: UILabel!
    @IBOutlet weak var powerDownButton: LoadingButton!
    
    var viewModel: ConfirmPowerViewModel!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setUpViews()
        setUpRxObservers()
    }
}

// MARK: - Preparations & Tools
extension ConfirmPowerDownViewController {
    
    func setUpViews() {
        self.amountLabel.textColor = ColorName.primary.color
        self.powerDownButton.primaryStyle()
    }
}

// MARK: - SetUp RxObservers
extension ConfirmPowerDownViewController {
    
    func setUpRxObservers() {
        setUpContentChangedObservers()
        setUpViewToPresentObservers()
    }
    
    func setUpContentChangedObservers() {
        self.disposeBag ~ [
            self.viewModel.amount ~> self.amountLabel.rx.text,
            self.viewModel.fromAccount ~> self.fromUsernameLabel.rx.text
        ]
        
        self.powerDownButton.rx.tap.asObservable()
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
