//
//  NotificationTableCell.swift
//  SereyIO
//
//  Created by Panha Uy on 9/28/21.
//  Copyright © 2021 Serey IO. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift
import RxBinding
import Then
import SnapKit
import Shimmer
import RxKingfisher

class NotificationTableCell: BaseTableViewCell {
    
    var shimmerView: FBShimmeringView!
    var mainView: UIView!
    lazy var profileView : ProfileView = {
        return .init().then {
            $0.snp.makeConstraints { make in
                make.width.height.equalTo(48)
            }
        }
    }()
    
    lazy var captionLabel: UILabel = {
        return .createLabel(16).then {
            $0.numberOfLines = 0
            $0.snp.makeConstraints { make in
                make.height.greaterThanOrEqualTo(16)
                make.width.greaterThanOrEqualTo(160)
            }
        }
    }()
    
    lazy var createdAtLabel: UILabel = {
        return .createLabel(14, textColor: .color("#696969")).then {
            $0.snp.makeConstraints { make in
                make.height.greaterThanOrEqualTo(14)
                make.width.greaterThanOrEqualTo(60)
            }
        }
    }()
    
    lazy var postThumbnailImageView: UIImageView = {
        return .init().then {
            $0.contentMode = .scaleAspectFill
            $0.clipsToBounds = true
            $0.setRadius(all: 8)
            $0.backgroundColor = ColorName.shimmering.color.withAlphaComponent(0.5)
            $0.snp.makeConstraints { make in
                make.width.height.equalTo(48)
            }
        }
    }()
    
    var cellModel: NotificationCellViewModel? {
        didSet {
            guard let cellModel = self.cellModel else { return }
            
            self.disposeBag ~ [
                cellModel.profileViewModel ~> self.profileView.rx.profileViewModel,
                cellModel.captionAttributedString ~> self.captionLabel.rx.attributedText,
                cellModel.createdAt ~> self.createdAtLabel.rx.text,
                cellModel.backgroundColor ~> self.contentView.rx.backgroundColor,
                cellModel.isThumbnailHidden ~> self.postThumbnailImageView.rx.isHidden,
                cellModel.thumbnailUrl.map { $0 }.bind(to: self.postThumbnailImageView.kf.rx.image())
            ]
            
            cellModel.isShimmering.asObservable()
                .subscribe(onNext: { [weak self] isShimmering in
                    self?.prepareShimmering(isShimmering)
                }) ~ self.disposeBag
        }
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        loadViews()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
}

// MARK: - Load Views
extension NotificationTableCell {
    
    func loadViews() {
        self.shimmerView = .init().then {
            $0.shimmeringSpeed = 400
        }
        self.contentView.addSubview(self.shimmerView)
        self.shimmerView.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(16)
            make.top.bottom.equalToSuperview().inset(8)
        }
        
        let mainStackView = UIStackView().then {
            $0.axis = .horizontal
            $0.spacing = 8
            $0.alignment = .center
            
            let captionStackView = UIStackView().then {
                $0.spacing = 4
                $0.axis = .vertical
                $0.alignment = .leading
                
                $0.addArrangedSubview(self.captionLabel)
                $0.addArrangedSubview(self.createdAtLabel)
                $0.contentHuggingPriority(for: .horizontal)
            }
            
            $0.addArrangedSubview(self.profileView)
            $0.addArrangedSubview(captionStackView)
            $0.addArrangedSubview(self.postThumbnailImageView)
        }
        
        self.mainView = .init()
        mainView.addSubview(mainStackView)
        mainStackView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        self.contentView.addSubview(mainView)
        self.mainView.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(16)
            make.top.bottom.equalToSuperview().inset(8)
        }
        self.shimmerView.contentView = mainView
        self.backgroundColor = .white
    }
}

// MARK: - Preparations & Tools
extension NotificationTableCell {
    
    private func prepareShimmering(_ isShimmering: Bool) {
        let backgroundColor = isShimmering ? ColorName.shimmering.color.withAlphaComponent(0.5) : UIColor.clear
        let cornerRadius : CGFloat = isShimmering ? 8 : 0
        
        self.profileView.backgroundColor = backgroundColor
        self.captionLabel.backgroundColor = backgroundColor
        self.captionLabel.setRadius(all: cornerRadius)
        
        self.createdAtLabel.backgroundColor = backgroundColor
        self.createdAtLabel.setRadius(all: cornerRadius)
        
        DispatchQueue.main.async {
            self.shimmerView.isShimmering = isShimmering
        }
    }
}
