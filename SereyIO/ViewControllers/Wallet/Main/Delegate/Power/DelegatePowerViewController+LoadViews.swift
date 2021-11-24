//
//  DelegatePowerViewController+LoadViews.swift
//  SereyIO
//
//  Created by Panha Uy on 11/3/21.
//  Copyright © 2021 Serey IO. All rights reserved.
//

import UIKit
import SnapKit
import MaterialComponents
import Then

extension DelegatePowerViewController {
    
    func prepareViews() -> UIView {
        let mainView = UIView()
        mainView.backgroundColor = .white
        
        mainView.addSubview(self.headerView)
        self.headerView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.left.right.equalToSuperview()
        }
        
        mainView.addSubview(self.contentView)
        self.contentView.snp.makeConstraints { make in
            make.top.equalTo(self.headerView.snp.bottom).inset(12)
            make.left.right.equalToSuperview()
            make.bottom.equalToSuperview()
        }
        
        self.accountTextField = .init().then {
            $0.keyboardType = .default
            $0.autocapitalizationType = .none
            $0.autocorrectionType = .no
            $0.leftView = UIImageView(image: R.image.accountIcon()).then { $0.tintColor = .gray }
            $0.leftViewMode = .always
        }
        self.accountTextField.primaryStyle()
        
        self.amountTextField = .init().then {
            $0.keyboardType = .decimalPad
            $0.leftView = UIImageView(image: R.image.amountIcon()).then { $0.tintColor = .gray }
            $0.leftViewMode = .always
        }
        self.amountTextField.primaryStyle()
        let formStackView = UIStackView().then {
            $0.spacing = 22
            $0.axis = .vertical
            
            $0.addArrangedSubview(self.accountTextField)
            $0.addArrangedSubview(self.amountTextField)
        }
        
        self.contentView.addSubview(formStackView)
        formStackView.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(24)
            make.left.right.equalToSuperview().inset(24)
        }
        
        self.delegateButton = .init().then {
            $0.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
            $0.setTitleColor(.white, for: .normal)
        }
        self.delegateButton.primaryStyle()
        
        self.contentView.addSubview(self.delegateButton)
        self.delegateButton.snp.makeConstraints { make in
            make.height.equalTo(46)
            make.left.right.equalToSuperview().inset(24)
            make.bottom.equalTo(self.contentView.safeAreaLayoutGuide.snp.bottom).inset(16)
        }
        
        return mainView
    }
}
