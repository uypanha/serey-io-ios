//
//  FilterHeaderCollectionViewCell.swift
//  SereyMarket
//
//  Created by Panha Uy on 5/10/21.
//  Copyright © 2021 Serey Marketplace. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift
import RxBinding

class FilterHeaderCollectionViewCell: BaseCollectionViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var resetButton: UIButton!
    @IBOutlet weak var widthConstraint: NSLayoutConstraint!
    
    var cellModel: FilterHeaderCellViewModel? {
        didSet {
            guard let cellModel = self.cellModel else { return }
            
            self.disposeBag ~ [
                cellModel.isResetEnabled ~> self.resetButton.rx.isEnabled
            ]
            
            setUpRxObservers()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // Initialization code
        self.titleLabel.textColor = .black
        self.resetButton.setTitleColor(ColorName.almostRed.color, for: .normal)
        self.resetButton.customStyle(with: .clear)
    }
    
    func updateSize(_ size: CGSize) {
        self.widthConstraint.constant = size.width - 48
    }
}

// MARK: - SetUp RxObservers
extension FilterHeaderCollectionViewCell {
    
    func setUpRxObservers() {
        self.resetButton.rx.tap.asObservable()
            .subscribe(onNext: { [weak self] _ in
                self?.cellModel?.resetPressed()
            }) ~ self.disposeBag
    }
}
