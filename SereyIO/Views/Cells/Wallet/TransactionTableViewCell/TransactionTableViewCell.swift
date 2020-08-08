//
//  TransactionTableViewCell.swift
//  SereyIO
//
//  Created by Panha Uy on 8/6/20.
//  Copyright © 2020 Phanha Uy. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift
import RxBinding
import Shimmer

class TransactionTableViewCell: BaseTableViewCell {
    
    @IBOutlet weak var shimmerView: FBShimmeringView!
    @IBOutlet weak var mainView: UIView!
    
    @IBOutlet weak var typeImageView: UIImageView!
    @IBOutlet weak var typeLabel: UILabel!
    @IBOutlet weak var timeStampLabel: UILabel!
    @IBOutlet weak var valueLabel: UILabel!
    
    var cellModel: TransactionCellViewModel? {
        didSet {
            guard let cellModel = self.cellModel else { return }
            
            self.disposeBag ~ [
                cellModel.typeImage ~> self.typeImageView.rx.image,
                cellModel.typeText ~> self.typeLabel.rx.text,
                cellModel.timeStamp ~> self.timeStampLabel.rx.text,
                cellModel.valueText ~> self.valueLabel.rx.text,
                cellModel.valueColor.asObservable()
                    .subscribe(onNext: { [weak self] color in
                        self?.valueLabel.textColor = color
                    }),
                cellModel.isShimmering.asObservable()
                    .subscribe(onNext: { [weak self] isShimmering in
                        self?.prepareShimmering(isShimmering)
                    })
            ]
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        
        // Initialization code
        self.shimmerView.contentView = self.mainView
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.typeImageView.setRadius(all: self.typeImageView.frame.height / 2)
    }
}

// MARK: - Preparations & Tools
extension TransactionTableViewCell {
    
    func prepareShimmering(_ isShimmering: Bool) {
        let backgroundColor = isShimmering ? ColorName.shimmering.color.withAlphaComponent(0.5) : UIColor.clear
        let cornerRadius : CGFloat = isShimmering ? 8 : 0
        
        self.typeImageView.backgroundColor = backgroundColor
        
        self.typeLabel.backgroundColor = backgroundColor
        self.typeLabel.setRadius(all: cornerRadius)
        
        self.timeStampLabel.backgroundColor = backgroundColor
        self.timeStampLabel.setRadius(all: cornerRadius)
        
        self.valueLabel.backgroundColor = backgroundColor
        self.valueLabel.setRadius(all: cornerRadius)
        
        DispatchQueue.main.async {
            self.shimmerView.isShimmering = isShimmering
        }
    }
}
