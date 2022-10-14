//
//  ProductCategoryCollectionViewCell.swift
//  SereyMarket
//
//  Created by Panha Uy on 5/10/21.
//  Copyright © 2021 Serey Marketplace. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift
import RxBinding
import MaterialComponents

class ProductCategoryCollectionViewCell: MDCChipCollectionViewCell {

    var disposeBag: DisposeBag!
    
    var cellModel: ProductCategoryCellViewModel? {
        didSet {
            self.disposeBag = .init()
            guard let cellModel = self.cellModel else { return }
            
            self.chipView.titleLabel.text = cellModel.cateoryName.value

            self.disposeBag ~ [
                cellModel.isSelected.asObservable()
                    .subscribe(onNext: { [weak self] isSelected in
                        DispatchQueue.main.async {
                            self?.isSelected = isSelected
                        }
                    })
            ]
        }
    }
}
