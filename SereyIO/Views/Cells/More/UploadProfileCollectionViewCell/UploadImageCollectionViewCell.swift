//
//  UploadImageCollectionViewCell.swift
//  SereyIO
//
//  Created by Mäd on 28/12/2021.
//  Copyright © 2021 Serey IO. All rights reserved.
//

import UIKit
import SnapKit
import RxCocoa
import RxSwift
import RxBinding
import Then

class UploadImageCollectionViewCell: BaseCollectionViewCell {
    
    lazy var iconImageView: UIImageView = {
        return .init(image: R.image.uploadProfileBigIcon()).then {
            $0.tintColor = UIColor(hexString: "#A7A7A7")
            $0.contentMode = .scaleAspectFit
        }
    }()
    
    var cellModel: UploadImageCellViewModel? {
        didSet {
            guard let cellModel = self.cellModel else { return }
            
            cellModel.image ~> self.iconImageView.rx.image ~ self.disposeBag
        }
    }
    
    var widthConstraint: ConstraintMakerEditable!
    var heightConstraint: ConstraintMakerEditable!
 
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        loadViews()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        loadViews()
    }
    
    func updateSize(_ size: CGSize) {
        self.widthConstraint.constraint.update(offset: size.width).activate()
        self.heightConstraint.constraint.update(offset: size.height).activate()
    }
    
    func setHighlighted(_ highlighted: Bool, animated: Bool) {
        UIView.animate(withDuration: animated ? 0.3 : 0, animations: {
            self.contentView.alpha = highlighted ? 0.5 : 1.0
        })
    }
}

// MARK: - LoadViews
extension UploadImageCollectionViewCell {
    
    func loadViews() {
        let mainView = DashBorderView().then {
            $0.borderColor = UIColor(hexString: "#A7A7A7")
            $0.borderWidth = 3
            $0.cornerRadius = 19
        }
        
        let infoStackView = UIStackView().then {
            $0.axis = .vertical
            $0.alignment = .center
            $0.spacing = 6
            
            $0.addArrangedSubview(self.iconImageView)
            self.iconImageView.snp.makeConstraints { make in
                make.width.height.equalTo(48)
            }
            
            let uploadLabel: UILabel = .createLabel(18, weight: .medium, textColor: UIColor(hexString: "#A7A7A7"))
            uploadLabel.text = "Upload"
            $0.addArrangedSubview(uploadLabel)
        }
        mainView.addSubview(infoStackView)
        infoStackView.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(10)
            make.centerY.equalToSuperview()
        }
        
        self.contentView.addSubview(mainView)
        mainView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            self.widthConstraint = make.width.equalTo(150)
            self.heightConstraint = make.height.equalTo(150)
        }
    }
}
