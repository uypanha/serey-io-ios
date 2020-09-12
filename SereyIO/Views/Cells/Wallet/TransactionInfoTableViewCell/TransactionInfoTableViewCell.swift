//
//  TransactionInfoTableViewCell.swift
//  SereyIO
//
//  Created by Panha Uy on 9/9/20.
//  Copyright © 2020 Phanha Uy. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift
import RxBinding

class TransactionInfoTableViewCell: BaseTableViewCell {

    @IBOutlet weak var typeLabel: UILabel!
    @IBOutlet weak var typeDescriptionLabel: UILabel!
    
    var cellModel: TransactionInfoCellViewModel? {
        didSet {
            guard let cellModel = self.cellModel else { return }
            
            self.disposeBag ~ [
                cellModel.typeTitle ~> self.typeLabel.rx.text,
                cellModel.typeDescription ~> self.typeDescriptionLabel.rx.text
            ]
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        self.selectionStyle = .none
    }
}
