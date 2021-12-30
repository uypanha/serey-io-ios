//
//  ProfileGalleryViewController+LoadViews.swift
//  SereyIO
//
//  Created by Mäd on 27/12/2021.
//  Copyright © 2021 Serey IO. All rights reserved.
//

import UIKit
import Then
import SnapKit

extension ProfileGalleryViewController {
    
    func prepareViews() -> UIView {
        let mainView = ViewHelper.prepareScrollView { contentView in
            let infoStackView = UIStackView().then {
                $0.axis = .vertical
                $0.spacing = 16
                
                $0.addArrangedSubview(self.titleLabel)
                
                let descriptionStackView = UIStackView().then {
                    $0.axis = .vertical
                    
                    $0.addArrangedSubview(self.tipsLabel)
                    $0.addArrangedSubview(self.tipsDescriptionLabel)
                }
                $0.addArrangedSubview(descriptionStackView)
            }
            contentView.addSubview(infoStackView)
            infoStackView.snp.makeConstraints { make in
                make.left.top.right.equalToSuperview().inset(16)
            }
            
            contentView.addSubview(self.collectionView)
            self.collectionView.snp.makeConstraints { make in
                make.top.equalTo(infoStackView.snp.bottom).offset(16)
                make.left.right.bottom.equalToSuperview()
            }
        }
        
        mainView.backgroundColor = .white
        return mainView
    }
}
