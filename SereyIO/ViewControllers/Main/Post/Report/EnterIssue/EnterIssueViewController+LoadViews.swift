//
//  EnterIssueViewController+LoadViews.swift
//  SereyIO
//
//  Created by Mäd on 01/02/2022.
//  Copyright © 2022 Serey IO. All rights reserved.
//

import UIKit
import SnapKit
import Then


extension EnterIssueViewController {
    
    func prepareViews() -> UIView {
        let mainView = UIView()
        
        let infoStackView = UIStackView().then {
            $0.axis = .vertical
            $0.spacing = 17
            
            $0.addArrangedSubview(self.titleLabel)
            $0.addArrangedSubview(self.textField)
            $0.addArrangedSubview(self.reportButton)
        }
        
        mainView.addSubview(infoStackView)
        infoStackView.snp.makeConstraints { make in
            make.left.top.right.equalToSuperview().inset(16)
        }
        
        mainView.backgroundColor = .white
        return mainView
    }
}
