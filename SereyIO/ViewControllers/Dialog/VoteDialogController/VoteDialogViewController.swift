//
//  VoteDialogViewController.swift
//  SereyIO
//
//  Created by Panha Uy on 4/16/20.
//  Copyright © 2020 Serey IO. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift
import RxBinding

class VoteDialogViewController: BaseViewController {
    
    @IBOutlet weak var titleContainerView: UIView!
    @IBOutlet weak var voteTitleLabel: UILabel!
    @IBOutlet weak var progressValueLabel: UILabel!
    @IBOutlet weak var progressSlider: UISlider!
    @IBOutlet weak var confirmButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    
    var presentingController: UIViewController?
    
    var viewModel: VoteDialogViewModel!
    
    init(_ presentingViewController: UIViewController?) {
        super.init(nibName: R.nib.voteDialogViewController.name, bundle: R.nib.voteDialogViewController.bundle)
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
extension VoteDialogViewController {
    
    func setUpViews() {
        self.titleContainerView.addBorders(edges: [.bottom], color: .color(.border))
        self.confirmButton.primaryStyle()
        self.cancelButton.secondaryStyle()
        
        if let parentController = self.presentingController {
            self.cancelButton.addTarget(parentController, action: #selector(UIViewController.tapLSDialogBackgroundView(_:)), for: .touchUpInside)
            self.confirmButton.addTarget(parentController, action:#selector(UIViewController.tapLSDialogBackgroundView(_:)), for: .touchUpInside)
        }
    }
}

// MARK: - SetUp RxObservers
extension VoteDialogViewController {
    
    func setUpRxObservers() {
        setUpContentChangedObservers()
        setUpControlsObservers()
    }
    
    func setUpContentChangedObservers() {
        self.viewModel.pregressText ~> self.progressValueLabel.rx.text ~ self.disposeBag
        self.viewModel.titleText ~> self.voteTitleLabel.rx.text ~ self.disposeBag
    }
    
    func setUpControlsObservers() {
        (self.progressSlider.rx.value <-> self.viewModel.voteCount) ~ self.disposeBag
        
        self.viewModel.maximum.asObservable()
            .subscribe(onNext: { [weak self] maximum in
                self?.progressSlider.maximumValue = maximum
            }) ~ self.disposeBag
        
        self.confirmButton.rx.tap.map { VoteDialogViewModel.Action.confirmPressed }
            ~> self.viewModel.didActionSubject
            ~ self.disposeBag
            
        self.cancelButton.rx.tap.asObservable()
            .subscribe(onNext: { [weak self] _ in
                self?.dismissDialogViewController(.zoomInOut)
            }) ~ self.disposeBag
    }
}
