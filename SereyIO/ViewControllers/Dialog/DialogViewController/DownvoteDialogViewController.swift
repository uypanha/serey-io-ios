//
//  DownvoteDialogViewController.swift
//  SereyIO
//
//  Created by Panha Uy on 4/22/20.
//  Copyright © 2020 Phanha Uy. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift
import RxBinding

class DownvoteDialogViewController: BaseViewController {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var confirmButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    
    var presentingController: UIViewController?
    var viewModel: DownvoteDialogViewModel!
    
    init(_ presentingViewController: UIViewController?) {
        super.init(nibName: R.nib.downvoteDialogViewController.name, bundle: R.nib.downvoteDialogViewController.bundle)
        self.presentingController = presentingViewController
    }
    
    required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setUpViews()
        setUpRxObservers()
    }
    
    override func setUpLocalizedTexts() {
        super.setUpLocalizedTexts()
        
        self.confirmButton.setTitle(R.string.common.confirm.localized(), for: .normal)
        self.cancelButton.setTitle(R.string.common.cancel.localized(), for: .normal)
    }
}

// MARK: - Preparations & Tools
extension DownvoteDialogViewController {
    
    func setUpViews() {
        self.confirmButton.primaryStyle()
        self.cancelButton.secondaryStyle()
        
        if let parentController = self.presentingController {
            self.cancelButton.addTarget(parentController, action: #selector(UIViewController.tapLSDialogBackgroundView(_:)), for: .touchUpInside)
            self.confirmButton.addTarget(parentController, action:#selector(UIViewController.tapLSDialogBackgroundView(_:)), for: .touchUpInside)
        }
    }
}

// MARK: - SetUp RxObservers
extension DownvoteDialogViewController {
    
    func setUpRxObservers() {
        setUpContentChangedObservers()
        setUpControlsObservers()
    }
    
    func setUpContentChangedObservers() {
        self.viewModel.titleText ~> self.titleLabel.rx.text ~ self.disposeBag
        self.viewModel.messageText ~> self.messageLabel.rx.text ~ self.disposeBag
    }
    
    func setUpControlsObservers() {
        self.confirmButton.rx.tap.map { DownvoteDialogViewModel.Action.confirmPressed }
            ~> self.viewModel.didActionSubject
            ~ self.disposeBag
        
        self.cancelButton.rx.tap.asObservable()
            .subscribe(onNext: { [weak self] _ in
                self?.dismissDialogViewController(.zoomInOut)
            }) ~ self.disposeBag
    }
}
