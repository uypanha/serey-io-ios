//
//  ProfileCollectionViewCell.swift
//  SereyIO
//
//  Created by Mäd on 27/12/2021.
//  Copyright © 2021 Serey IO. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift
import RxBinding
import Shimmer
import Kingfisher
import RxKingfisher
import SnapKit

class ProfileCollectionViewCell: BaseCollectionViewCell {
    
    lazy var shimmerView: FBShimmeringView = {
        return .init()
    }()
    
    lazy var mainView: CardView = {
        return .init().then {
            $0.showShadow = false
            $0.backgroundColor = .white
            $0.cornerRadius = 19
            $0.clipsToBounds = true
            $0.borderColor = .lightGray.withAlphaComponent(0.3)
            $0.borderWidth = 1
        }
    }()
    
    lazy var profileImageView: UIImageView = {
        return .init().then {
            $0.backgroundColor = ColorName.shimmering.color.withAlphaComponent(0.5)
        }
    }()
    
    lazy var actionButton: UIButton = {
        return .init().then {
            $0.setImage(R.image.removeIcon(), for: .normal)
            $0.setBackgroundColor(UIColor(hexString: "#F35050").withAlphaComponent(0.58), for: .normal)
            $0.imageEdgeInsets = .init(top: 3, left: 3, bottom: 3, right: 3)
            $0.tintColor = .white
            $0.setRadius(all: 12)
        }
    }()
    
    var widthConstraint: ConstraintMakerEditable!
    var heightConstraint: ConstraintMakerEditable!
    
    var cellModel: ProfilePictureCellViewModel? {
        didSet {
            guard let cellModel = self.cellModel else { return }
            
            self.disposeBag ~ [
                cellModel.profileUrl.map { $0 }.bind(to: self.profileImageView.kf.rx.image()),
                cellModel.buttonImage ~> self.actionButton.rx.image(for: .normal),
                cellModel.buttonBackgroundColor
                    .subscribe(onNext: { [weak self] color in
                        self?.actionButton.setBackgroundColor(color, for: .normal)
                    }),
                cellModel.isSelected
                    .subscribe(onNext: { [weak self] isSelected in
                        self?.mainView.borderColor = isSelected ? .color(.primary) : ColorName.shimmering.color.withAlphaComponent(0.5)
                        self?.mainView.borderWidth = isSelected ? 3 : 1
                    })
            ]
            
            cellModel.isShimmering.asObservable()
                .subscribe(onNext: { [weak self] isShimmering in
                    self?.prepareShimmering(isShimmering)
                }) ~ self.disposeBag
            
            self.actionButton.rx.tap.asObservable()
                .map { ProfilePictureCellViewModel.Action.actionButtonPressed }
                ~> cellModel.didActionSubject
                ~ self.disposeBag
        }
    }
    
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

// MARK: - Preparations & Tools
extension ProfileCollectionViewCell {
    
    func prepareShimmering(_ isShimmering: Bool) {
        let isHidden = isShimmering
        
        self.actionButton.isHidden = isHidden
        
        DispatchQueue.main.async {
            self.shimmerView.isShimmering = isShimmering
        }
    }
}

// MARK: - PreparViews
extension ProfileCollectionViewCell {
    
    func loadViews() {
        let mainView = UIView()
        
        mainView.addSubview(self.shimmerView)
        self.shimmerView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        mainView.addSubview(self.mainView)
        self.mainView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        self.mainView.addSubview(self.profileImageView)
        self.profileImageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        self.mainView.addSubview(self.actionButton)
        self.actionButton.snp.makeConstraints { make in
            make.right.bottom.equalToSuperview().inset(8)
            make.width.height.equalTo(24)
        }
        
        self.contentView.addSubview(mainView)
        mainView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            self.widthConstraint = make.width.equalTo(150)
            self.heightConstraint = make.height.equalTo(150)
        }
        
        self.shimmerView.contentView = self.mainView
    }
}
