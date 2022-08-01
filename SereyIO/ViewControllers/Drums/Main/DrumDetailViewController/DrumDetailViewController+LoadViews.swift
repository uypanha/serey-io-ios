//
//  DrumDetailViewController+LoadViews.swift
//  SereyIO
//
//  Created by Panha Uy on 20/7/22.
//  Copyright © 2022 Serey IO. All rights reserved.
//

import UIKit
import Then
import SnapKit

extension DrumDetailViewController {
    
    func prepareViews() -> UIView {
        let mainView = UIView()
        
        let scrollView = ViewHelper.prepareScrollView { contentView in
            contentView.addSubview(self.detailView)
            self.detailView.snp.makeConstraints { make in
                make.left.right.top.equalToSuperview()
            }
            
            contentView.addSubview(self.tableView)
            self.tableView.snp.makeConstraints { make in
                make.height.greaterThanOrEqualTo(100)
                make.left.right.bottom.equalToSuperview()
                make.top.equalTo(self.detailView.snp.bottom).offset(16)
            }
        }
        
        self.commentContainerView = .init(true).then {
            $0.shadowOffsetHeight = -1
        }
        self.commentContainerView.addSubview(self.commentView)
        self.commentView.snp.makeConstraints { make in
            make.left.right.top.equalToSuperview().inset(16)
            make.bottom.equalTo(self.commentContainerView.safeAreaLayoutGuide.snp.bottom).inset(16)
        }
        
        mainView.addSubview(scrollView)
        scrollView.snp.makeConstraints { make in
            make.left.right.top.equalToSuperview()
            self.bottomConstraint = make.bottom.equalToSuperview().constraint.layoutConstraints.first
        }
        
        mainView.addSubview(self.commentContainerView)
        self.commentContainerView.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.bottom.equalTo(scrollView.snp.bottom)
        }
        
        return mainView
    }
}
