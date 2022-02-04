//
//  ConfirmCancelDelegateViewController.swift
//  SereyIO
//
//  Created by Panha Uy on 11/9/21.
//  Copyright © 2021 Serey IO. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift
import RxBinding

class ConfirmDialogViewController: BaseViewController, BottomSheetProtocol {
    
    var preferredBottomSheetContentSize: CGSize? {
        let preferedSize = CGSize(width: self.view.frame.width, height: self.containerView.frame.height)
        return preferedSize
    }
    
    var containerView: UIView!
    lazy var titleLabel: UILabel = {
        return .createLabel(17, weight: .semibold, textColor: .black)
    }()
    
    lazy var messageLabel: UILabel = {
        return .createLabel(16, weight: .regular)
    }()
    
    lazy var confirmButton: LoadingButton = {
        return .init()
    }()
    
    var viewModel: ConfirmDialogViewModel!
    
    init(_ viewModel: ConfirmDialogViewModel) {
        super.init(nibName: nil, bundle: nil)
        
        self.viewModel = viewModel
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setUpViews()
        setUpRxObservers()
    }
}

// MARK: - Preparations & Tools
extension ConfirmDialogViewController {
    
    func setUpViews() {
        let mainView = self.prepareViews()
        self.view.addSubview(mainView)
        mainView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        self.confirmButton.primaryStyle()
    }
}

// MARK: - SetUp RxObservers
extension ConfirmDialogViewController {
    
    func setUpRxObservers() {
        self.titleLabel.text = self.viewModel.title
        self.messageLabel.text = self.viewModel.message
        
        if let action = viewModel.actions.first {
            self.confirmButton.setTitle(action.title, for: .normal)
            self.confirmButton.primaryStyle()
        }
        
        self.confirmButton.rx.tap.asObservable()
            .subscribe(onNext: { [weak self] _ in
                self?.dismiss(animated: true, completion: {
                    self?.viewModel.actions.first?.completion()
                })
            }) ~ self.disposeBag
    }
}
