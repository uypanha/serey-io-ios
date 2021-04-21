//
//  PeopleTableViewCell.swift
//  SereyIO
//
//  Created by Phanha Uy on 3/4/20.
//  Copyright © 2020 Serey IO. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift
import RxBinding
import Shimmer

class PeopleTableViewCell: BaseTableViewCell {
    
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var vwShimmer: FBShimmeringView!

    @IBOutlet weak var profileView: ProfileView!
    @IBOutlet weak var profileNameLabel: UILabel!
    
    var cellModel: PeopleCellViewModel? {
        didSet {
            guard let cellModel = self.cellModel else { return }
            
            self.disposeBag ~ [
                cellModel.nameText ~> self.profileNameLabel.rx.text,
                cellModel.profileModel ~> self.profileView.rx.profileViewModel,
                cellModel.isShimmering.asObservable()
                    .subscribe(onNext: { [weak self] isShimmering in
                        self?.prepareShimmering(isShimmering)
                    })
            ]
            
            cellModel.indicatorAccessory
                .map { $0 ? ViewUtiliesHelper.prepareIndicatorAccessory() : nil }
                .subscribe(onNext: { [weak self] indicatorView in
                    self?.accessoryView = indicatorView
                }) ~ self.disposeBag
            
            cellModel.selectionType
                .subscribe(onNext: { [weak self] selectionStyle in
                    self?.selectionStyle = selectionStyle
                }) ~ self.disposeBag
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        self.vwShimmer.contentView = self.mainView
    }
}

// MARK: - Preparations & Tools
extension PeopleTableViewCell {
    
    private func prepareShimmering(_ isShimmering: Bool) {
        let backgroundColor = isShimmering ? ColorName.shimmering.color.withAlphaComponent(0.5) : UIColor.clear
        let cornerRadius : CGFloat = isShimmering ? 8 : 0
        
        self.profileView.backgroundColor = backgroundColor
        self.profileNameLabel.backgroundColor = backgroundColor
        self.profileNameLabel.setRadius(all: cornerRadius)
        
        DispatchQueue.main.async {
            self.vwShimmer.isShimmering = isShimmering
        }
    }
}
