//
//  DelegatedUserTableViewCell.swift
//  SereyIO
//
//  Created by Panha Uy on 12/10/22.
//  Copyright © 2022 Serey IO. All rights reserved.
//

import UIKit
import Then
import SnapKit
import RxCocoa
import RxSwift
import RxBinding
import SkeletonView

class DelegatedUserTableViewCell: BaseTableViewCell {
    
    lazy var profileView: ProfileView = {
        return .init(frame: .init()).then {
            $0.backgroundColor = .blue
            $0.isSkeletonable = true
        }
    }()
    
    lazy var profileName: UILabel = {
        return .createLabel(17, weight: .regular, textColor: .black).then {
            $0.isSkeletonable = true
            $0.linesCornerRadius = 4
            $0.lastLineFillPercent = Int.random(in: (30...60))
            $0.withMinHeight(16)
        }
    }()
    
    lazy var powerAmountLabel: UILabel = {
        return .createLabel(13, weight: .regular, textColor: .black).then {
            $0.isSkeletonable = true
            $0.linesCornerRadius = 4
            $0.lastLineFillPercent = Int.random(in: (60...80))
            $0.withMinHeight(14)
        }
    }()
    
    lazy var removeButton: UIButton = {
        return .init().then {
            $0.setImage(R.image.removeIcon(), for: .normal)
            $0.setBackgroundColor(UIColor(hexString: "#F35050").withAlphaComponent(0.58), for: .normal)
            $0.imageEdgeInsets = .init(top: 3, left: 3, bottom: 3, right: 3)
            $0.tintColor = .white
            $0.setRadius(all: 12)
        }
    }()

    var cellModel: DelegatedUserCellViewModel? {
        didSet {
            guard let cellModel = self.cellModel else { return }
            
            cellModel.profileName ~> self.profileName.rx.text ~ self.disposeBag
            cellModel.powerAmount ~> self.powerAmountLabel.rx.text ~ self.disposeBag
            cellModel.profileViewModel ~> self.profileView.rx.profileViewModel ~ self.disposeBag
            
            cellModel.isShimmering.asObservable()
                .subscribe(onNext: { [weak self] isShimmering in
                    self?.removeButton.isHidden = isShimmering
                    DispatchQueue.main.async {
                        self?.profileView.setSkeletonView(isShimmering)
                        self?.profileName.setSkeletonView(isShimmering)
                        self?.powerAmountLabel.setSkeletonView(isShimmering)
                    }
                }) ~ self.disposeBag
            
            self.removeButton.rx.tap.asObservable()
                .subscribe(onNext: { _ in
                    cellModel.handleRemoveDelegatePressed()
                }) ~ self.disposeBag
        }
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setUpViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Preparations & Tools
extension DelegatedUserTableViewCell {
    
    func setUpViews() {
        let containerView = UIStackView().then {
            $0.axis = .horizontal
            $0.spacing = 16
            $00.alignment = .center
            
            $0.addArrangedSubview(self.profileView)
            
            let infoStackView = UIStackView().then {
                $0.axis = .vertical
                $0.spacing = 4
                
                $0.addArrangedSubview(self.profileName)
                $0.addArrangedSubview(self.powerAmountLabel)
            }
            $0.addArrangedSubview(infoStackView)
            $0.addArrangedSubview(self.removeButton)
        }
        
        self.removeButton.snp.makeConstraints { make in
            make.width.height.equalTo(24)
        }
        
        self.profileView.snp.makeConstraints { make in
            make.width.height.equalTo(40)
        }
        
        self.contentView.addSubview(containerView)
        containerView.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(16)
            make.top.bottom.equalToSuperview().inset(8)
        }
        
        self.selectionStyle = .none
    }
}
