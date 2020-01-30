//
//  LanguageTableViewCell.swift
//  Emergency
//
//  Created by Phanha Uy on 9/21/19.
//  Copyright © 2019 Phanha Uy. All rights reserved.
//

import UIKit

class LanguageTableViewCell: BaseTableViewCell {

    @IBOutlet weak var languageImageView: UIImageView!
    @IBOutlet weak var languageLabel: UILabel!
    
    var cellModel: LanguageCellViewModel? {
        didSet {
            guard let viewModel = self.cellModel else {
                return
            }
            
            viewModel.image.bind(to: self.languageImageView.rx.image).disposed(by: self.disposeBag)
            viewModel.titleText.bind(to: self.languageLabel.rx.text).disposed(by: self.disposeBag)
            viewModel.indicatorAccessory
                .map { $0 ? ViewUtiliesHelper.prepareIndicatorAccessory() : nil }
                .subscribe(onNext: { [weak self] indicatorView in
                    self?.accessoryView = indicatorView
                }).disposed(by: self.disposeBag)
        }
    }
}
