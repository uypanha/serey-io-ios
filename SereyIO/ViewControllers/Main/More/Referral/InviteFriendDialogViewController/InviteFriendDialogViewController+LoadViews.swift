//
//  InviteFriendDialogViewController+LoadViews.swift
//  SereyIO
//
//  Created by Panha on 1/4/22.
//  Copyright © 2022 Serey IO. All rights reserved.
//

import UIKit
import Then
import SnapKit

extension InviteFriendDialogViewController {
    
    func prepareViews() -> UIView {
        let mainView = UIView()
        mainView.backgroundColor = .clear
        
        self.containerView = CardView()
        containerView.backgroundColor = .white
        containerView.cornerRadius = 10
        containerView.showShadow = false
        
        mainView.addSubview(containerView)
        containerView.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(24)
            make.bottom.equalTo(mainView.safeAreaLayoutGuide.snp.bottom).inset(24)
        }
        
        let mainStackView = UIStackView().then {
            $0.axis = .vertical
            $0.distribution = .fillProportionally
            $0.spacing = 32
            
            let titleStackView = UIStackView().then {
                $0.axis = .horizontal
                $0.distribution = .fill
                
                $0.addArrangedSubview(self.titleLabel)
                $0.addArrangedSubview(self.closeButton)
                self.closeButton.snp.makeConstraints { make in
                    make.width.height.equalTo(24)
                }
            }
            $0.addArrangedSubview(titleStackView)
            
            let copyLinkContainer = UIStackView().then {
                $0.spacing = 12
                $0.axis = .vertical
                
                let inviteWithLinkLabel = UILabel.createLabel(12, weight: .semibold, textColor: .color("#9DACBF")).then {
                    $0.text = "Or invite with link"
                    $0.textAlignment = .center
                    $0.snp.makeConstraints { make in
                        make.height.equalTo(24)
                    }
                }
                $0.addArrangedSubview(inviteWithLinkLabel)
                
                let referralContainer = DashBorderView()
                referralContainer.borderWidth = 0
                referralContainer.backgroundColor = .color("#FAFAFA")
                referralContainer.cornerRadius = 8
                $0.addArrangedSubview(referralContainer)
                
                let referralStackView = UIStackView().then {
                    $0.axis = .horizontal
                    $0.spacing = 4
                    $0.alignment = .center
                    
                    $0.addArrangedSubview(self.referralLinkLabel)
                    $0.addArrangedSubview(self.copyLinkButton)
                }
                referralContainer.addSubview(referralStackView)
                referralStackView.snp.makeConstraints { make in
                    make.edges.equalToSuperview().inset(16)
                    make.height.greaterThanOrEqualTo(24)
                }
            }
            $0.addArrangedSubview(copyLinkContainer)
        }
        containerView.addSubview(mainStackView)
        mainStackView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(24)
        }
        
        return mainView
    }
}
