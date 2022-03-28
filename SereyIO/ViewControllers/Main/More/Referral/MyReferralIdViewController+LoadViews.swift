//
//  MyReferralIdViewController+LoadViews.swift
//  SereyIO
//
//  Created by Mäd on 22/03/2022.
//  Copyright © 2022 Serey IO. All rights reserved.
//

import UIKit
import Then
import SnapKit

extension MyReferralIdViewController {
    
    internal func prepareViews() -> UIView {
        let mainView = UIView()
        mainView.backgroundColor = .color("#F7F8FD")
        
        let mainStackView = UIStackView().then {
            $0.axis = .vertical
            $0.spacing = 36
            
            let imageView = UIImageView(image: R.image.referralImage())
            imageView.contentMode = .scaleAspectFit
            imageView.snp.makeConstraints { make in
                make.height.equalTo(139)
            }
            $0.addArrangedSubview(imageView)
            
            let infoStackView = UIStackView().then {
                $0.axis = .vertical
                $0.spacing = 16
                
                $0.addArrangedSubview(self.titleLabel)
                $0.addArrangedSubview(self.messageLabel)
            }
            $0.addArrangedSubview(infoStackView)
            
            let referralContainer = DashBorderView()
            referralContainer.borderColor = .color(.primary)
            referralContainer.borderWidth = 2
            referralContainer.backgroundColor = .color("#D7DEF6")
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
            }
        }
        
        mainView.addSubview(mainStackView)
        mainStackView.snp.makeConstraints { make in
            make.right.left.equalToSuperview().inset(24)
            make.top.equalToSuperview().inset(48)
        }
        
        mainView.addSubview(self.inviteButton)
        self.inviteButton.snp.makeConstraints { make in
            make.height.equalTo(52)
            make.left.right.equalToSuperview().inset(24)
            make.bottom.equalTo(mainView.safeAreaLayoutGuide.snp.bottom).inset(24)
        }
        
        return mainView
    }
}
