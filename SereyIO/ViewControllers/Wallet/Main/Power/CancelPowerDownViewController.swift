//
//  CancelPowerDownViewController.swift
//  SereyIO
//
//  Created by Panha Uy on 9/4/20.
//  Copyright © 2020 Phanha Uy. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift
import RxBinding

class CancelPowerDownViewController: BaseViewController, BottomSheetProtocol, AlertDialogController, LoadingIndicatorController {
    
    var preferredBottomSheetContentSize: CGSize? {
        let preferedSize = CGSize(width: self.view.frame.width, height: self.containerView.frame.height)
        return preferedSize
    }
    
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var cancelPowerDownButton: LoadingButton!
    
    var viewModel: CancelPowerDownViewModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        setUpViews()
        setUpRxObservers()
    }
}

// MARK: - Preparations & Tools
extension CancelPowerDownViewController {
    
    func setUpViews() {
        self.cancelPowerDownButton.primaryStyle()
    }
}

// MARK: - SetUp RxObservers
extension CancelPowerDownViewController {
    
    func setUpRxObservers() {
        setUpControlObservers()
        setUpViewToPresentObservers()
        setUpShouldPresentErrorObservers()
    }
    
    func setUpControlObservers() {
        self.cancelPowerDownButton.rx.tap.asObservable()
            .map { CancelPowerDownViewModel.Action.cancelPowerDownPressed }
            ~> self.viewModel.didActionSubject
            ~ self.disposeBag
    }
    
    func setUpViewToPresentObservers() {
        self.viewModel.shouldPresent.asObservable()
            .subscribe(onNext: { [weak self] viewToPresent in
                switch viewToPresent {
                case .loading(let loading):
                    loading ? self?.showLoading() : self?.dismissLoading()
                case .dismiss:
                    self?.dismiss(animated: true, completion: nil)
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
