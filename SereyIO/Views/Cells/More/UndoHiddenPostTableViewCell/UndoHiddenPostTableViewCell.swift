//
//  UndoHiddenPostTableViewCell.swift
//  SereyIO
//
//  Created by Mäd on 07/02/2022.
//  Copyright © 2022 Serey IO. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift
import RxBinding
import SnapKit

class UndoHiddenPostTableViewCell: BaseTableViewCell {
    
    lazy var titleLabel: UILabel = {
        return .createLabel(16, weight: .bold, textColor: .black)
    }()
    
    lazy var descriptionLabel: UILabel = {
        return .createLabel(13, weight: .medium, textColor: .color("#767676"))
    }()
    
    lazy var undoButton: UIButton = {
        return .createButton(with: 14, weight: .medium).then {
            $0.primaryStyle()
            $0.setRadius(all: 4)
            $0.contentEdgeInsets = .init(top: 0, left: 16, bottom: 0, right: 16)
        }
    }()
    
    var cellModel: UndoHiddenPostCellViewModel? {
        didSet {
            self.undoButton.setTitle("Undo", for: .normal)
            self.titleLabel.text = "Post hidden"
            self.descriptionLabel.text = "You won’t see this post in your feed."
            
            guard let cellModel = self.cellModel else {
                return
            }
            
            self.undoButton.rx.tap.asObservable()
                .map { _ in cellModel.post }
                ~> cellModel.shouldUnhidePost
                ~ self.disposeBag
        }
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.prepareViews()
        self.selectionStyle = .none
        self.separatorInset = .init(top: 0, left: 16, bottom: 0, right: 16)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Preparations & Tools
extension UndoHiddenPostTableViewCell {
    
    func prepareViews() {
        let mainView = UIView()
        let iconImageView = UIImageView(image: R.image.iconHiddenPost())
        mainView.addSubview(iconImageView)
        iconImageView.snp.makeConstraints { make in
            make.top.left.equalToSuperview()
        }
        
        let textStackView = UIStackView().then {
            $0.axis = .vertical
            $0.spacing = 4
            
            $0.addArrangedSubview(self.titleLabel)
            $0.addArrangedSubview(self.descriptionLabel)
        }
        mainView.addSubview(textStackView)
        textStackView.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview()
            make.left.equalTo(iconImageView.snp.right).offset(10)
        }
        
        mainView.addSubview(self.undoButton)
        self.undoButton.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.right.equalToSuperview()
            make.height.equalTo(30)
        }
        
        self.contentView.addSubview(mainView)
        mainView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(16)
        }
    }
}
