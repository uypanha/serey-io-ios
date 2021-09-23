//
//  SubPostCategoryCollectionViewCell.swift
//  SereyIO
//
//  Created by Phanha Uy on 2/18/20.
//  Copyright © 2020 Serey IO. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift
import RxBinding
import MaterialComponents

class SubPostCategoryCollectionViewCell: BaseCollectionViewCell {
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var checkedView: UIImageView!
    @IBOutlet weak var chipView: UIView!
    
    var cellModel: CategoryCellViewModel? {
        didSet {
            guard let cellModel = self.cellModel else { return }
            
            cellModel.titleLabelText.asObservable()
                ~> self.nameLabel.rx.text
                ~ self.disposeBag
            
            cellModel.isSelected.asObservable()
                .map { !$0 }
                ~> self.checkedView.rx.isHidden
                ~ self.disposeBag
            
            cellModel.isSelected.asObservable()
                .map { $0 ? UIColor.lightGray : UIColor.lightGray.withAlphaComponent(0.2) }
                ~> self.chipView.rx.backgroundColor
                ~ self.disposeBag
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        self.chipView.makeMeCircular()
        self.chipView.backgroundColor = UIColor.lightGray.withAlphaComponent(0.2)
    }
}
