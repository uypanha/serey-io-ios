//
//  TextTableViewCell.swift
//  SereyIO
//
//  Created by Panha Uy on 3/25/20.
//  Copyright © 2020 Serey IO. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift
import RxBinding

class TextTableViewCell: BaseTableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var leadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var trailingConstraint: NSLayoutConstraint!
    
    var cellModel: TextCellViewModel? {
        didSet {
            guard let cellModel = self.cellModel else { return }
            
            self.disposeBag ~ [
                cellModel.titleLabelText.bind(to: self.titleLabel.rx.text),
                cellModel.labelProperties.asObservable()
                    .subscribe(onNext: { [weak self] properties in
                        self?.prepareFormProperties(withProperties: properties)
                    }),
                cellModel.indicatorAccessory
                    .subscribe(onNext: { [weak self] indicatorAccessory in
                        self?.accessoryView = indicatorAccessory ? ViewUtiliesHelper.prepareIndicatorAccessory() : nil
                    }),
                cellModel.isSelectionEnabled
                    .subscribe(onNext: { [weak self] isSelectionEnabled in
                        self?.selectionStyle = isSelectionEnabled ? .default : .none
                    }),
                cellModel.isShimmering.asObservable()
                    .subscribe(onNext: { [weak self] isShimmering in
                        DispatchQueue.main.async {
                            self?.titleLabel.lastLineFillPercent = Int.random(in: 50...90)
                            self?.titleLabel.setSkeletonView(isShimmering)
                        }
                    })
            ]
        }
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

