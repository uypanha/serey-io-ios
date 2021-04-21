//
//  TextTableViewCell.swift
//  SereyIO
//
//  Created by Panha Uy on 3/25/20.
//  Copyright © 2020 Serey IO. All rights reserved.
//

import UIKit

class TextTableViewCell: BaseTableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var leadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var trailingConstraint: NSLayoutConstraint!
    
    var cellModel: TextCellViewModel? {
        didSet {
            guard let cellModel = self.cellModel else { return }
            
            cellModel.titleLabelText.bind(to: self.titleLabel.rx.text).disposed(by: self.disposeBag)
            
            cellModel.labelProperties.asObservable()
                .subscribe(onNext: { [weak self] properties in
                    self?.prepareFormProperties(withProperties: properties)
                }).disposed(by: self.disposeBag)
            
            cellModel.indicatorAccessory
                .subscribe(onNext: { [weak self] indicatorAccessory in
                    self?.accessoryView = indicatorAccessory ? UIImageView(image: R.image.accessoryIcon()?.image(withTintColor: ColorName.primary.color)) : nil
                }).disposed(by: self.disposeBag)
            
            cellModel.isSelectionEnabled
                .subscribe(onNext: { [weak self] isSelectionEnabled in
                    self?.selectionStyle = isSelectionEnabled ? .default : .none
                }).disposed(by: self.disposeBag)
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
    }
}

extension TextTableViewCell {
    
    internal func prepareFormProperties(withProperties properties: TextLabelProperties) {
        if let font = properties.font {
            self.titleLabel.font = font
        }
        
        if let textColor = properties.textColor {
            self.titleLabel.textColor = textColor
        }
        
        if let backgroundColor = properties.backgroundColor {
            self.backgroundColor = backgroundColor
        }
        
        if let alignment = properties.textAlignment {
            self.titleLabel.textAlignment = alignment
        }
        
        self.leadingConstraint.constant = properties.leadingTrailingConstant
        self.trailingConstraint.constant = properties.leadingTrailingConstant
    }
}

