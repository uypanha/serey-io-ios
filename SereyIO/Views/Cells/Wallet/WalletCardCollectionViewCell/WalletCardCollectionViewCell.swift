//
//  WalletCardCollectionViewCell.swift
//  SereyIO
//
//  Created by Panha Uy on 7/1/20.
//  Copyright © 2020 Serey IO. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift
import RxBinding
import Shimmer

class WalletCardCollectionViewCell: BaseCollectionViewCell {
    
    @IBOutlet weak var cardView: CardView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var valueLabel: UILabel!
    @IBOutlet weak var vwShimmer: FBShimmeringView!
    @IBOutlet weak var sereyLabel: UILabel!
    
    @IBOutlet weak var sereyImageView: UIImageView!
    @IBOutlet weak var cardHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var cardWidthConstraint: NSLayoutConstraint!
    
    var cellModel: WalletCardCellViewModel? {
        didSet {
            guard let cellModel = self.cellModel else { return }
            
            self.disposeBag ~ [
                cellModel.titleText ~> self.titleLabel.rx.text,
                cellModel.cardColor ~> self.cardView.rx.backgroundColor,
                cellModel.valueText ~> self.valueLabel.rx.text,
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
        
        self.vwShimmer.contentView = self.cardView
    }
    
    func updateSized(_ size: CGSize) {
        self.cardHeightConstraint.constant = size.height
        self.cardWidthConstraint.constant = size.width
    }
}

// MARK: - Preparations & Tools
extension WalletCardCollectionViewCell {
    
    func prepareShimmering(_ isShimmering: Bool) {
        let backgroundColor = isShimmering ? ColorName.shimmering.color.withAlphaComponent(0.5) : UIColor.clear
        let textColor = isShimmering ? ColorName.shimmering.color.withAlphaComponent(0.5) : UIColor.white
        let cornerRadius : CGFloat = isShimmering ? 8 : 0
        
        self.titleLabel.backgroundColor = backgroundColor
        self.titleLabel.setRadius(all: cornerRadius)
        self.titleLabel.textColor = textColor
        self.valueLabel.backgroundColor = backgroundColor
        self.valueLabel.textColor = textColor
        self.valueLabel.setRadius(all: cornerRadius)
        self.sereyLabel.backgroundColor = backgroundColor
        self.sereyLabel.textColor = textColor
        self.sereyLabel.setRadius(all: cornerRadius)
        self.sereyImageView.isHidden = isShimmering
        
        if isShimmering {
            self.cardView.backgroundColor = ColorName.shimmering.color
        }
        
        DispatchQueue.main.async {
            self.vwShimmer.isShimmering = isShimmering
        }
    }
}
