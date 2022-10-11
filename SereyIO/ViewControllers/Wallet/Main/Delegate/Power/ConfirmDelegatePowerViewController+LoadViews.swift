//
//  ConfirmDelegatePowerViewController+LoadViews.swift
//  SereyIO
//
//  Created by Panha Uy on 11/4/21.
//  Copyright © 2021 Serey IO. All rights reserved.
//

import UIKit
import Then
import SnapKit

extension ConfirmDelegatePowerViewController {
    
    func prepareViews() -> UIView {
        let mainView = UIView()
        mainView.backgroundColor = .white
        
        let contentView = UIView().then {
            $0.backgroundColor = .white
        }
        let mainStackView = UIStackView().then {
            $0.axis = .vertical
            $0.spacing = 24
            
            let amountStackView = UIStackView().then {
                $0.axis = .horizontal
                $0.spacing = 12
                $0.alignment = .center
                
                let presentView = CardView().then {
                    $0.cornerRadius = 54 / 2
                    $0.backgroundColor = .color("#E5F2DC")
                    $0.showShadow = false
                }
                
                let iconImageView = UIImageView(image: R.image.delegatePowerIcon())
                presentView.addSubview(iconImageView)
                iconImageView.snp.makeConstraints { make in
                    make.width.height.equalTo(16)
                    make.center.equalToSuperview()
                }
                
                $0.addArrangedSubview(presentView)
                presentView.snp.makeConstraints { make in
                    make.height.width.equalTo(54)
                }
                
                let amountLabelsStackView = UIStackView().then {
                    $0.axis = .vertical
                    $0.spacing = 4
                    
                    $0.addArrangedSubview(self.totalAmountLabel)
                    $0.addArrangedSubview(self.amountLabel)
                }
                $0.addArrangedSubview(amountLabelsStackView)
            }
            
            $0.addArrangedSubview(amountStackView)
            
            let fromAccountStackView = UIStackView().then {
                $0.axis = .vertical
                $0.spacing = 4
                
                $0.addArrangedSubview(self.fromLabel)
                $0.addArrangedSubview(self.fromUsernameLabel)
            }
            $0.addArrangedSubview(fromAccountStackView)
            
            let toAccountStackView = UIStackView().then {
                $0.axis = .vertical
                $0.spacing = 4
                
                $0.addArrangedSubview(self.toLabel)
                $0.addArrangedSubview(self.toUsernameLabel)
            }
            $0.addArrangedSubview(toAccountStackView)
            $0.addArrangedSubview(self.delegateButton)
        }
        contentView.addSubview(mainStackView)
        mainStackView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(16)
        }
        
        let indicatorView = CardView().then {
            $0.backgroundColor = .lightGray
            $0.cornerRadius = 4
            $0.showShadow = false
        }
        
        mainView.addSubview(contentView)
        contentView.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.top.greaterThanOrEqualToSuperview()
            make.bottom.equalTo(mainView.safeAreaLayoutGuide.snp.bottom)
        }
        
        mainView.addSubview(indicatorView)
        indicatorView.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(16)
            make.centerX.equalToSuperview()
            make.height.equalTo(4)
            make.width.equalTo(60)
        }
        return mainView
    }
}
