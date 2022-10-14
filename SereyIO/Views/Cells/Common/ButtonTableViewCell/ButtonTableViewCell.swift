//
//  ButtonTableViewCell.swift
//  SereyIO
//
//  Created by Phanha Uy on 12/26/19.
//  Copyright © 2020 Serey IO. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift
import RxBinding

class ButtonTableViewCell: BaseTableViewCell {

    @IBOutlet weak var actionButton: UIButton!
    
    var cellModel: ButtonCellViewModel? {
        didSet {
            guard let cellModel = self.cellModel else {
                return
            }
            
            cellModel.titleText.bind(to: self.actionButton.rx.title(for: .normal)).disposed(by: self.disposeBag)
            cellModel.properties.subscribe(onNext: { [weak self] properties in
                self?.prepareProperties(properties)
            }) ~ self.disposeBag
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        setUpRxObservers()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // Initialization code
        setUpRxObservers()
    }
}

// MARK: - Preparations & Tools
extension ButtonTableViewCell {
    
    fileprivate func prepareProperties(_ properties: ButtonProperties) {
        if let font = properties.font {
            self.actionButton.titleLabel?.font = font
        }
        
        if let textColor = properties.textColor {
            self.actionButton.setTitleColor(textColor, for: .normal)
        }
        
        if let backgroundColor = properties.backgroundColor {
            self.actionButton.customStyle(with: backgroundColor)
        }
        
        self.actionButton.customBorderStyle(with: properties.borderColor ?? .clear, border: 1, isCircular: properties.isCircular)
    }
}

// MARK: - SetUp RxObservers
extension ButtonTableViewCell {
    
    func setUpRxObservers() {
        self.actionButton.rx.tap
            .subscribe(onNext: { [weak self] _ in
                self?.cellModel?.shouldFireButtonAction.onNext(())
            }).disposed(by: self.disposeBag)
    }
}
