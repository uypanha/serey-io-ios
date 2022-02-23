//
//  HeaderCollectionViewCell.swift
//  SereyMarket
//
//  Created by Panha Uy on 5/10/21.
//  Copyright © 2021 Serey Marketplace. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift
import RxBinding

class HeaderCollectionViewCell: BaseCollectionViewCell {

    @IBOutlet weak var headerLabel: UILabel!
    @IBOutlet weak var widthConstraint: NSLayoutConstraint!
    
    var cellModel: HeaderCellViewModel? {
        didSet {
            guard let cellModel = self.cellModel else { return }
            
            self.disposeBag ~ [
                cellModel.title ~> self.headerLabel.rx.text
            ]
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // Initialization code
        self.headerLabel.textColor = .black
    }
    
    func updateSize(_ size: CGSize) {
        self.widthConstraint.constant = size.width - 48
    }
}
