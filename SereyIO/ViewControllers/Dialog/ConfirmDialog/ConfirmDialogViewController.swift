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
    
    var onConfirmDidPressed: () -> Void = {}
    
    init(_ title: String, message: String, buttonTItle: String = R.string.common.confirm.localized(), completion: @escaping () -> Void = {}) {
        super.init(nibName: nil, bundle: nil)
        
        self.titleLabel.text = title
        self.messageLabel.text = message
        self.confirmButton.setTitle(buttonTItle, for: .normal)
        self.onConfirmDidPressed = completion
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
        self.confirmButton.rx.tap.asObservable()
            .subscribe(onNext: { [weak self] _ in
                self?.onConfirmDidPressed()
            }) ~ self.disposeBag
    }
}
