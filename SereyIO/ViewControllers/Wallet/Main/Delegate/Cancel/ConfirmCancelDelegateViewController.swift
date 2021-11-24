//
//  ConfirmCancelDelegateViewController.swift
//  SereyIO
//
//  Created by Panha Uy on 11/9/21.
//  Copyright © 2021 Serey IO. All rights reserved.
//

import UIKit

class ConfirmCancelDelegateViewController: BaseViewController, BottomSheetProtocol {
    
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
    
    lazy var cancelPowerDownButton: LoadingButton = {
        return .init()
    }()
    
    var viewModel: ConfirmDelegatePowerViewModel!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setUpViews()
    }
    
    override func setUpLocalizedTexts() {
        super.setUpLocalizedTexts()
        
        self.cancelPowerDownButton.setTitle("Cancel Delegate", for: .normal)
        self.titleLabel.text = "Cancel delegation from \"Rithy\"?"
        self.messageLabel.text = "Are you sure you want to cancel delegate power?"
    }
}

// MARK: - Preparations & Tools
extension ConfirmCancelDelegateViewController {
    
    func setUpViews() {
        let mainView = self.prepareViews()
        self.view.addSubview(mainView)
        mainView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        self.cancelPowerDownButton.primaryStyle()
    }
}
