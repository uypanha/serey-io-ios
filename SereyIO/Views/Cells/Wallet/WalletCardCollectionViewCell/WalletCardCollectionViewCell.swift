//
//  WalletCardCollectionViewCell.swift
//  SereyIO
//
//  Created by Panha Uy on 7/1/20.
//  Copyright © 2020 Phanha Uy. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift
import RxBinding

class WalletCardCollectionViewCell: BaseCollectionViewCell {
    
    @IBOutlet weak var cardView: CardView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var valueLabel: UILabel!
    
    @IBOutlet weak var cardHeightConstraint: NSLayoutConstraint!
    
    var cellModel: WalletCardCellViewModel? {
        didSet {
            guard let cellModel = self.cellModel else { return }
            
            self.disposeBag ~ [
                cellModel.titleText ~> self.titleLabel.rx.text,
                cellModel.cardColor ~> self.cardView.rx.backgroundColor
            ]
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
}
