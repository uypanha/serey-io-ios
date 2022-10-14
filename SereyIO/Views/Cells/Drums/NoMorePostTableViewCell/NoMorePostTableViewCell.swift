//
//  NoMorePostTableViewCell.swift
//  SereyIO
//
//  Created by Panha Uy on 12/7/22.
//  Copyright © 2022 Serey IO. All rights reserved.
//

import UIKit
import Then
import SnapKit
import RxCocoa
import RxSwift
import RxBinding

class NoMorePostTableViewCell: BaseTableViewCell {
    
    lazy var titleLabel: UILabel = {
        return .createLabel(12, weight: .medium, textColor: .color("#9D9D9D"))
    }()
    
    var cellModel: NoMorePostCellViewModel? {
        didSet {
            guard let cellModel = cellModel else {
                return
            }
            
            self.disposeBag ~ [
                cellModel.title ~> self.titleLabel.rx.text
            ]
        }
    }

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
extension NoMorePostTableViewCell {
    
    func setUpLayout() {
        let titleStackView = UIStackView().then {
            $0.addArrangedSubview(self.titleLabel)
        }
        let containerView = UIView()
        containerView.addSubview(titleStackView)
        containerView.snp.makeConstraints { make in
            make.height.equalTo(36)
        }
        
        titleStackView.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }

        let leftLineView = UIView().then {
            $0.backgroundColor = .color("#E2E2E2")
            $0.withHeight(1.5)
        }

        let rightLineView = UIView().then {
            $0.backgroundColor = .color("#E2E2E2")
            $0.withHeight(1.5)
        }

        containerView.addSubview(leftLineView)
        containerView.addSubview(rightLineView)
        leftLineView.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.left.equalToSuperview().inset(16)
            make.right.equalTo(self.titleLabel.snp.left).offset(-12)
        }

        rightLineView.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.right.equalToSuperview().inset(16)
            make.left.equalTo(self.titleLabel.snp.right).offset(12)
        }
        
        self.contentView.addSubview(containerView)
        containerView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        self.selectionStyle = .none
        self.backgroundColor = .clear
        self.contentView.backgroundColor = .clear
    }
}
