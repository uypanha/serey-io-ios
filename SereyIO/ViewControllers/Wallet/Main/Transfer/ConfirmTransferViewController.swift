//
//  ConfirmTransferViewController.swift
//  SereyIO
//
//  Created by Panha Uy on 8/10/20.
//  Copyright © 2020 Serey IO. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift
import RxBinding

class ConfirmTransferViewController: BaseViewController, BottomSheetProtocol {
    
    var preferredBottomSheetContentSize: CGSize? {
        let preferedSize = CGSize(width: self.view.frame.width, height: 304 + 32 + 22)
        return preferedSize
    }

    @IBOutlet weak var totalAmountLabel: UILabel!
    @IBOutlet weak var amountLabel: UILabel!
    @IBOutlet weak var fromLabel: UILabel!
    @IBOutlet weak var fromUsernameLabel: UILabel!
    @IBOutlet weak var toLabel: UILabel!
    @IBOutlet weak var toUsernameLabel: UILabel!
    @IBOutlet weak var transferButton: LoadingButton!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var memoLabel: UILabel!
    
    var viewModel: ConfirmTransferViewModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setUpViews()
        setUpRxObservers()
    }
    
    override func setUpLocalizedTexts() {
        super.setUpLocalizedTexts()
        
        self.transferButton.setTitle("Transfer", for: .normal)
    }
}

// MARK: - Preparations & Tools
extension ConfirmTransferViewController {
    
    func setUpViews() {
        self.amountLabel.textColor = .color(.primary)
        self.transferButton.primaryStyle()
    }
}

// MARK: - SetUp RxObservers
extension ConfirmTransferViewController {
    
    func setUpRxObservers() {
        setUpContentChangedObservers()
        setUpViewToPresentObservers()
    }
    
    func setUpContentChangedObservers() {
        self.disposeBag ~ [
            self.viewModel.amount ~> self.amountLabel.rx.text,
            self.viewModel.fromUsername ~> self.fromUsernameLabel.rx.text,
            self.viewModel.toUsername ~> self.toUsernameLabel.rx.text,
            self.viewModel.memo ~> self.memoLabel.rx.text
        ]
        
        self.transferButton.rx.tap.asObservable()
            .map { ConfirmTransferViewModel.Action.transferPressed }
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
