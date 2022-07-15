//
//  QuotedDrumCollectionViewCell.swift
//  SereyIO
//
//  Created by Panha Uy on 15/7/22.
//  Copyright © 2022 Serey IO. All rights reserved.
//

import UIKit
import Then
import SnapKit
import MaterialComponents

class QuotedDrumCollectionViewCell: BaseCollectionViewCell {
    
    lazy var containerView: CardView = {
        return .init(false).then {
            $0.borderColor = .color(.border)
            $0.borderWidth = 1
            $0.cornerRadius = 18
            
            $0.withMinHeight(100)
        }
    }()
    
    var rippleController: MDCRippleTouchController!
    
    var cellModel: QuotedDrumCellViewModel? {
        didSet {
            
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setUpLayout()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        setUpLayout()
    }
}

// MARK: - Preparations & Tools
private extension QuotedDrumCollectionViewCell {
    
    func setUpLayout() {
        self.backgroundColor = .clear
        self.contentView.backgroundColor = .clear
        
        self.contentView.addSubview(self.containerView)
        self.containerView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        self.rippleController = .init(view: self.containerView)
    }
}
