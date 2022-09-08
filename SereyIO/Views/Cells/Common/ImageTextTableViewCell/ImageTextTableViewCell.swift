//
//  ImageTextTableViewCell.swift
//  SereyIO
//
//  Created by Panha Uy on 3/26/20.
//  Copyright © 2020 Serey IO. All rights reserved.
//

import UIKit
import Kingfisher
import RxCocoa
import RxSwift
import RxKingfisher
import RxBinding

class ImageTextTableViewCell: BaseTableViewCell {
    
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var titleTextLabel: UILabel!
    @IBOutlet weak var subTitleLabel: UILabel!
    @IBOutlet weak var trailingConstraint: NSLayoutConstraint!
    
    var cellModel: ImageTextCellViewModel? {
        didSet {
            self.iconImageView.image = nil
            guard let viewModel = self.cellModel else {
                return
            }
            
            viewModel.image.filter { $0 != nil }.bind(to: self.iconImageView.rx.image).disposed(by: self.disposeBag)
            viewModel.imageUrl.filter { $0 != nil }.map { URL(string: $0!) }.bind(to: self.iconImageView.kf.rx.image()).disposed(by: self.disposeBag)
            viewModel.titleText.filter { $0 != nil }.bind(to: self.titleTextLabel.rx.text).disposed(by: self.disposeBag)
            viewModel.attributedText.filter { $0 != nil }.bind(to: self.titleTextLabel.rx.attributedText).disposed(by: self.disposeBag)
            viewModel.subTitle.bind(to: self.subTitleLabel.rx.text).disposed(by: self.disposeBag)
            viewModel.backgroundColor ~> self.rx.backgroundColor ~ self.disposeBag
            
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
                        self?.addBorder(edges: .bottom, color: .color(.border), thickness: 1)
                    }
                }).disposed(by: self.disposeBag)
            
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // Initialization code
        self.iconImageView.clipsToBounds = true
        self.iconImageView.contentMode = .scaleAspectFill
    }
}
