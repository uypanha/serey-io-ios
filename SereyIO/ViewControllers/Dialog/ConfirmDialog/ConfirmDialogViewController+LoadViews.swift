//
//  ConfirmCancelDelegateViewController+LoadViews.swift
//  SereyIO
//
//  Created by Panha Uy on 11/9/21.
//  Copyright © 2021 Serey IO. All rights reserved.
//

import UIKit

extension ConfirmDialogViewController {
    
    func prepareViews() -> UIView {
        let mainView = UIView()
        mainView.backgroundColor = .white
        
        self.containerView = .init()
        self.containerView.backgroundColor = .white
        let mainStackView = UIStackView().then {
            $0.axis = .vertical
            $0.spacing = 16
            
            let labelsStackView = UIStackView().then {
                $0.axis = .vertical
                $0.spacing = 12
                
                self.titleLabel.numberOfLines = 0
                $0.addArrangedSubview(self.titleLabel)
                self.messageLabel.numberOfLines = 0
                $0.addArrangedSubview(self.messageLabel)
            }
            
            $0.addArrangedSubview(labelsStackView)
            $0.addArrangedSubview(self.confirmButton)
        }
        
        self.confirmButton.snp.makeConstraints { make in
            make.height.equalTo(44)
        }
        self.containerView.addSubview(mainStackView)
        mainStackView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(24)
        }
        
        mainView.addSubview(self.containerView)
        self.containerView.snp.makeConstraints { make in
            make.right.left.equalToSuperview()
            make.bottom.equalTo(mainView.safeAreaLayoutGuide.snp.bottom)
        }
        return mainView
    }
}
