//
//  PostDrumsTableViewCell.swift
//  SereyIO
//
//  Created by Panha Uy on 21/6/22.
//  Copyright © 2022 Serey IO. All rights reserved.
//

import UIKit
import Then
import SnapKit

class PostDrumsTableViewCell: BaseTableViewCell {
    
    lazy var titleLabel: UILabel = {
        return .createLabel(14, weight: .regular, textColor: .color("#B6C6CF")).then {
            $0.text = "What’s on your mind?"
        }
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setUpLayout()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        setUpLayout()
    }
}

// MARK: - Preparations & Tools
extension PostDrumsTableViewCell {
    
    func setUpLayout() {
        let cardView = CardView()
        cardView.backgroundColor = .white
        cardView.cornerRadius = 21
        cardView.borderColor = .color("#F1F1F1")
        cardView.borderWidth = 1
        
        cardView.addSubview(self.titleLabel)
        self.titleLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.left.equalToSuperview().inset(16)
        }
        
        let imageView = UIImageView(image: R.image.rightArrowIcon())
        imageView.tintColor = .color("#B6C6CF")
        cardView.addSubview(imageView)
        imageView.snp.makeConstraints { make in
            make.right.equalToSuperview().inset(12)
            make.centerY.equalToSuperview()
        }
        
        self.contentView.addSubview(cardView)
        cardView.snp.makeConstraints { make in
            make.height.equalTo(42)
            make.left.right.equalToSuperview().inset(16)
            make.top.bottom.equalToSuperview().inset(8)
        }
        self.selectionStyle = .none
        self.backgroundColor = .clear
        self.contentView.backgroundColor = .clear
        self.rippleController.addRipple(to: cardView)
    }
}
