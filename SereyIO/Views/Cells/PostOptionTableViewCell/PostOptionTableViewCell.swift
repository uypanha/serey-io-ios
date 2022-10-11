//
//  PostOptionTableViewCell.swift
//  SereyIO
//
//  Created by Panha Uy on 10/5/22.
//  Copyright © 2022 Serey IO. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift
import RxBinding
import Then
import SnapKit

class PostOptionTableViewCell: BaseTableViewCell {
    
    var iconContaierView: CardView!
    lazy var iconImageView: UIImageView = {
        return .init().then {
            $0.tintColor = .black
        }
    }()
    
    lazy var titleLabel: UILabel = {
        return .createLabel(14, weight: .medium, textColor: .color(.title))
    }()
    
    lazy var subTitleLabel: UILabel = {
        return .createLabel(12, weight: .regular, textColor: .color(.subTitle))
    }()
    
    var cellModel: PostOptionCellViewModel? {
        didSet {
            guard let cellModel = cellModel else {
                return
            }
 
            self.disposeBag ~ [
                cellModel.icon ~> self.iconImageView.rx.image,
                cellModel.title ~> self.titleLabel.rx.text,
                cellModel.subTitle ~> self.subTitleLabel.rx.text
            ]
        }
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        prepareViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Preparations & Tools
extension PostOptionTableViewCell {
    
    func prepareViews() {
        self.iconContaierView = CardView()
        iconContaierView.cornerRadius = 21
        iconContaierView.showShadow = false
        iconContaierView.backgroundColor = .color("#E5E5E5")
        iconContaierView.addSubview(self.iconImageView)
        self.iconImageView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(18)
        }
        
        self.contentView.addSubview(iconContaierView)
        self.iconContaierView.snp.makeConstraints { make in
            make.left.equalToSuperview().inset(24)
            make.bottom.top.equalToSuperview().inset(12)
            make.width.height.equalTo(42)
        }
        
        let infoStackView = UIStackView().then {
            $0.axis = .vertical
            $0.spacing = 0
            
            $0.addArrangedSubview(self.titleLabel)
            $0.addArrangedSubview(self.subTitleLabel)
        }
        self.contentView.addSubview(infoStackView)
        infoStackView.snp.makeConstraints { make in
            make.left.equalTo(iconContaierView.snp.right).offset(14)
            make.centerY.equalToSuperview()
            make.right.equalToSuperview().inset(24)
        }
    }
}
