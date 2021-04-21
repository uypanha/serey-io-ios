//
//  WalletMenuCollectionViewCell.swift
//  SereyIO
//
//  Created by Panha Uy on 7/29/20.
//  Copyright © 2020 Serey IO. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift
import RxBinding

class WalletMenuCollectionViewCell: BaseCollectionViewCell {

    @IBOutlet weak var cardView: CardView!
    @IBOutlet weak var widthConstraint: NSLayoutConstraint!
    @IBOutlet weak var heightConstraint: NSLayoutConstraint!
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var menuTitleLabel: UILabel!
    @IBOutlet weak var subTitleLabel: UILabel!
    
    var cellModel: WalletMenuCellViewModel? {
        didSet {
            guard let cellModel = self.cellModel else { return }
            
            self.disposeBag ~ [
                cellModel.image ~> self.iconImageView.rx.image,
                cellModel.title ~> self.menuTitleLabel.rx.text,
                cellModel.subTitle ~> self.subTitleLabel.rx.text,
                cellModel.backgroundColor ~> self.cardView.rx.backgroundColor
            ]
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // Initialization code
        self.cardView.cornerRadius = 4
    }
    
    func updateSize(_ size: CGSize) {
        self.widthConstraint.constant = size.width
        self.heightConstraint.constant = size.height
    }
    
    func setHighlighted(_ highlighted: Bool, animated: Bool) {
        UIView.animate(withDuration: animated ? 0.3 : 0, animations: {
            self.cardView.backgroundColor = highlighted ? self.cellModel?.backgroundColor.value?.withAlphaComponent(0.5) : self.cellModel?.backgroundColor.value
        })
    }
}
