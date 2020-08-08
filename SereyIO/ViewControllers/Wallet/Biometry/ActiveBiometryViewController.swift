//
//  ActiveBiometryViewController.swift
//  SereyIO
//
//  Created by Panha Uy on 6/16/20.
//  Copyright © 2020 Phanha Uy. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift
import RxBinding

class ActiveBiometryViewController: BaseViewController {

    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var enableButton: UIButton!
    
    var viewModel: ActiveBiometryViewModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setUpViews()
        setUpRxObservers()
    }
    
    override func setUpLocalizedTexts() {
        super.setUpLocalizedTexts()
        
        self.enableButton.setTitle("Enable", for: .normal)
    }
}

// MARK: - Preparations & Tools
extension ActiveBiometryViewController {
    
    func setUpViews() {
        enableButton.primaryStyle()
    }
}

// MARK: - SetUp RxObservers
extension ActiveBiometryViewController {
    
    func setUpRxObservers() {
        setUpContentChangedObservers()
    }
    
    func setUpContentChangedObservers() {
        self.disposeBag ~ [
            self.viewModel.iconImage ~> self.iconImageView.rx.image,
            self.viewModel.titleText ~> self.titleLabel.rx.text,
            self.viewModel.descriptionText ~> self.descriptionLabel.rx.text
        ]
    }
}