//
//  EmptyOrErrorView.swift
//  SereyIO
//
//  Created by Phanha Uy on 6/5/19.
//  Copyright © 2020 Serey IO. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift

class EmptyOrErrorView: NibView {
    
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var actionButton: UIButton! {
        didSet {
            actionButton.setTitleColor(.color(.primary), for: .normal)
        }
    }
    @IBOutlet weak var topConstraint: NSLayoutConstraint!
    @IBOutlet weak var errorImageWidthContraint: NSLayoutConstraint!
    
    var imageWidthContraint: CGFloat = 0.5
    var topConstraintConstant: CGFloat = 0
    
    var viewModel: EmptyOrErrorViewModel? {
        didSet {
            guard let viewModel = viewModel else { return }
            
            viewModel.titleText.bind(to: self.titleLabel.rx.text).disposed(by: self.disposeBag)
            viewModel.actionButtonText.bind(to: self.actionButton.rx.title()).disposed(by: self.disposeBag)
            viewModel.iconImage.bind(to: iconImageView.rx.image).disposed(by: self.disposeBag)
            viewModel.iconImage.map { $0 == nil }.bind(to: self.iconImageView.rx.isHidden).disposed(by: self.disposeBag)
            
            viewModel.descriptionText
                .map { text -> NSAttributedString? in
                    if let text = text  {
                        let paragraphStyle = NSMutableParagraphStyle()
                        //line height size
                        paragraphStyle.lineSpacing = 1.4
                        paragraphStyle.alignment = .center
                        let attrString = NSMutableAttributedString(string: text)
                        attrString.addAttribute(NSAttributedString.Key.paragraphStyle, value: paragraphStyle, range: NSMakeRange(0, attrString.length))
                        return attrString
                    }
                    return nil
                }
                .bind(to: self.descriptionLabel.rx.attributedText)
                .disposed(by: self.disposeBag)
            
            viewModel.topOffset
                .filter { $0 != nil }
                .asDriver(onErrorJustReturn: self.topConstraintConstant)
                .drive(onNext: { [unowned self] topConstraint in
                    self.topConstraint.constant = self.topConstraintConstant + (topConstraint ?? 0)
                }).disposed(by: self.disposeBag)
            
            viewModel.imageWidthOffset
                .filter { $0 != nil }
                .asDriver(onErrorJustReturn: self.imageWidthContraint)
                .drive(onNext: { [unowned self] widthContraint in
                    self.imageWidthContraint = widthContraint ?? self.imageWidthContraint
                    self.errorImageWidthContraint = self.errorImageWidthContraint.changeMultiplier(multiplier: self.imageWidthContraint)
                }).disposed(by: self.disposeBag)
            
            actionButton.rx.tap
                .asObservable()
                .bind(to: viewModel.actionButtonPressed)
                .disposed(by: self.disposeBag)
            
            viewModel.shouldShowActionButton
                .map({ shouldShow -> Bool in
                    return !shouldShow
                })
                .bind(to: actionButton.rx.isHidden)
                .disposed(by: self.disposeBag)
        }
    }
    
    override func xibSetup() {
        super.xibSetup()
        
        self.actionButton.secondaryStyle()
    }
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        
        self.topConstraint.constant = self.topConstraintConstant
        self.errorImageWidthContraint = self.errorImageWidthContraint.changeMultiplier(multiplier: self.imageWidthContraint)
    }
}
