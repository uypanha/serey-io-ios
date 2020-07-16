//
//  SettingTableViewCell.swift
//  Emergency
//
//  Created by Phanha Uy on 12/4/19.
//  Copyright © 2019 Phanha Uy. All rights reserved.
//

import UIKit

class SettingTableViewCell: BaseTableViewCell {
    
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var titleTextLabel: UILabel!
    @IBOutlet weak var subTitleLabel: UILabel!
    @IBOutlet weak var trailingConstraint: NSLayoutConstraint!
    
    var cellModel: SettingCellViewModel? {
        didSet {
            guard let viewModel = self.cellModel else {
                return
            }
            
            viewModel.image.bind(to: self.iconImageView.rx.image).disposed(by: self.disposeBag)
            viewModel.titleText.bind(to: self.titleTextLabel.rx.text).disposed(by: self.disposeBag)
            viewModel.subTitle.bind(to: self.subTitleLabel.rx.text).disposed(by: self.disposeBag)
            viewModel.indicatorAccessory
                .map { $0 ? ViewUtiliesHelper.prepareIndicatorAccessory() : nil }
                .subscribe(onNext: { [weak self] indicatorView in
                    self?.accessoryView = indicatorView
                    self?.trailingConstraint.constant = indicatorView == nil ? 24 : 4
                }).disposed(by: self.disposeBag)
            viewModel.selectionType
                .subscribe(onNext: { [weak self] selectionStyle in
                    self?.selectionStyle = selectionStyle
                }).disposed(by: self.disposeBag)
            viewModel.showSeperatorLine.asObservable()
                .subscribe(onNext: { [weak self] showSeperatorLine in
                    self?.removeAllBorders()
                    if (showSeperatorLine) {
                        self?.addBorder(edges: .bottom, color: UIColor.lightGray.withAlphaComponent(0.5), thickness: 1)
                    }
                }).disposed(by: self.disposeBag)
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
}
