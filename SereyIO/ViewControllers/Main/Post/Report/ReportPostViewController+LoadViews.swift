//
//  ReportPostViewController+LoadViews.swift
//  SereyIO
//
//  Created by Mäd on 26/01/2022.
//  Copyright © 2022 Serey IO. All rights reserved.
//

import UIKit
import SnapKit
import Then

extension ReportPostViewController {
    
    func prepareViews() -> UIView {
        let mainView = ViewHelper.prepareScrollView { contentView in
            let infoStackView = UIStackView().then {
                $0.axis = .vertical
                $0.spacing = 8
                
                $0.addArrangedSubview(self.titleLabel)
                $0.addArrangedSubview(self.descriptionLabel)
            }
            contentView.addSubview(infoStackView)
            infoStackView.snp.makeConstraints { make in
                make.left.top.right.equalToSuperview().inset(16)
            }
            
            contentView.addSubview(self.tableView)
            self.tableView.snp.makeConstraints { make in
                make.top.equalTo(infoStackView.snp.bottom).inset(16)
                make.left.right.bottom.equalToSuperview()
            }
        }
        
        mainView.backgroundColor = .white
        return mainView
    }
}
