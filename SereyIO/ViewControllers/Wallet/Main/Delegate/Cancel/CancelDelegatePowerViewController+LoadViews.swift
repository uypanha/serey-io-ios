//
//  CancelDelegatePowerViewController+LoadViews.swift
//  SereyIO
//
//  Created by Panha Uy on 12/10/22.
//  Copyright © 2022 Serey IO. All rights reserved.
//

import UIKit
import Then
import SnapKit

extension CancelDelegatePowerViewController {
    
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
        
        self.contentView.addSubview(self.tableView)
        self.tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        return mainView
    }
}
