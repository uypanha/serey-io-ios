//
//  FeatureViewController.swift
//  SereyIO
//
//  Created by Panha Uy on 7/8/21.
//  Copyright © 2021 Serey IO. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift
import RxBinding

class FeatureViewController: BaseViewController, PageItemControllerProtocol {
    
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var stackView: UIStackView!
    
    var index: Int = 0
    var viewModel: FeatureViewModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpViews()
        setUpRxObservers()
    }
}

// MARK: - Preparations & Tools
extension FeatureViewController {
    
    func setUpViews() {
    }
}

// MARK: - SetUp RxObservers
extension FeatureViewController {
    
    func setUpRxObservers() {
        setUpContentChangedObservers()
    }
    
    func setUpContentChangedObservers() {
        self.viewModel.image ~> self.iconImageView.rx.image ~ self.disposeBag
        self.viewModel.title ~> self.titleLabel.rx.text ~ self.disposeBag
        self.viewModel.message ~> self.messageLabel.rx.text ~ self.disposeBag
    }
}
