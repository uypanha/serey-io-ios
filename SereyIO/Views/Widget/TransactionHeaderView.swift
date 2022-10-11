//
//  TransactionHeaderView.swift
//  SereyIO
//
//  Created by Panha Uy on 11/3/21.
//  Copyright © 2021 Serey IO. All rights reserved.
//

import UIKit
import SnapKit

class TransactionHeaderView: UIView {
    
    lazy var titleLabel: UILabel = {
        return .createLabel(24, weight: .medium, textColor: .white)
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        // Setup view from .xib file
        self.setUpViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        // Setup view from .xib file
        self.setUpViews()
    }
}

// MARK: - SetUp Views
extension TransactionHeaderView {
    
    func setUpViews() {
        self.backgroundColor = .color(.primary)
        self.addSubview(self.titleLabel)
        self.titleLabel.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(24)
            make.top.equalTo(self.safeAreaLayoutGuide.snp.top).inset(24)
            make.bottom.equalToSuperview().inset(32)
        }
    }
}
