//
//  DrumImageCollectionViewCell.swift
//  SereyIO
//
//  Created by Panha Uy on 5/7/22.
//  Copyright © 2022 Serey IO. All rights reserved.
//

import UIKit
import Then
import SnapKit
import RxCocoa
import RxSwift
import RxBinding
import RxKingfisher
import MaterialComponents

class DrumImageCollectionViewCell: BaseCollectionViewCell {
    
    lazy var imageView: UIImageView = {
        return .init().then {
            $0.backgroundColor = .color(.shimmering)
            $0.contentMode = .scaleAspectFill
        }
    }()
    
    lazy var plusCountView: UIView = {
        return .init().then {
            $0.backgroundColor = UIColor.black.withAlphaComponent(0.37)
        }
    }()
    
    lazy var moreImageCountLabel: UILabel = {
        return .createLabel(32, weight: .regular, textColor: .white)
    }()
    
    var widthConstraint: ConstraintMakerEditable!
    var heightConstraint: ConstraintMakerEditable!
    
    var cellModel: ImageCellViewModel? {
        didSet {
            guard let cellModel = cellModel else {
                return
            }

            self.disposeBag ~ [
                cellModel.imageUrl.map { $0 }.bind(to: self.imageView.kf.rx.image()),
                cellModel.plusImage.map { $0 == 0 } ~> self.plusCountView.rx.isHidden,
                cellModel.plusImage.map { "+\($0)" } ~> self.moreImageCountLabel.rx.text
            ]
        }
    }
    
    var rippleController: MDCRippleTouchController!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setUpLayout()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        setUpLayout()
    }
    
    func updateSize(_ size: CGSize) {
        self.widthConstraint.constraint.update(offset: size.width).activate()
        self.heightConstraint.constraint.update(offset: size.height).activate()
    }
}

// MARK: - Preparations & Tools
extension DrumImageCollectionViewCell {
    
    func setUpLayout() {
        self.backgroundColor = .clear
        self.contentView.backgroundColor = .clear
        self.contentView.setRadius(all: 8)
        self.contentView.addSubview(self.imageView)
        self.imageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            self.widthConstraint = make.width.equalTo(200)
            self.heightConstraint = make.height.equalTo(120)
        }
        
        self.contentView.addSubview(self.plusCountView)
        self.plusCountView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        self.plusCountView.addSubview(self.moreImageCountLabel)
        self.moreImageCountLabel.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        self.rippleController = .init(view: self.contentView)
    }
}
