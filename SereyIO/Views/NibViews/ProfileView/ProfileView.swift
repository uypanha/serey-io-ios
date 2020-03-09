//
//  ProfileView.swift
//  Emergency
//
//  Created by Phanha Uy on 3/8/19.
//  Copyright © 2019 Phanha Uy. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxBinding
import Kingfisher
import RxKingfisher

class ProfileView: NibView {

    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var shortcutNameLabel: UILabel!
    
    @IBOutlet weak var topConstraint: NSLayoutConstraint!
    @IBOutlet weak var leftConstraint: NSLayoutConstraint!
    @IBOutlet weak var rightConstraint: NSLayoutConstraint!
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    
    @IBInspectable var borderWidth: CGFloat = 1
    @IBInspectable var borderColor: UIColor = UIColor.lightGray.withAlphaComponent(0.2)
    
    private var marginPercentage: CGFloat =  0.2 {
        didSet {
            self.validateMargin()
        }
    }
    
    var viewModel: ProfileViewModel? {
        didSet {
            self.profileImageView.image = nil
            self.shortcutNameLabel.text = nil
            self.containerView.backgroundColor = .clear
            guard let viewModel = self.viewModel else { return }
            
            viewModel.shortcutLabel.asObservable()
                ~> self.shortcutNameLabel.rx.text
                ~ self.disposeBag
            
            viewModel.shortcutLabel.asObservable()
                .map { $0?.count == 1 ? 0.3 : 0.2 }
                .subscribe(onNext: { [weak self] marginPercentage in
                    self?.marginPercentage = CGFloat(marginPercentage)
                }) ~ self.disposeBag
            
            viewModel.imageURL.asObservable()
                .`do`(onNext: { [unowned self] (imageUrl) in
                    self.profileImageView.isHidden = imageUrl == nil
                    self.shortcutNameLabel.isHidden = imageUrl != nil
                })
                .filter { $0 != nil }
                .map { $0 }
                .bind(to: self.profileImageView.kf.rx.image(options: [.processor(ResizingImageProcessor(referenceSize: CGSize(width: 500, height: 500), mode: .aspectFill))]))
                ~ self.disposeBag
            
            viewModel.uniqueColor.asObservable()
                ~> self.containerView.rx.backgroundColor
                ~ self.disposeBag
        }
    }
    
    override func styleUI() {
        super.styleUI()
    
        self.makeMeCircular()
        self.setBorder(borderWith: borderWidth, borderColor: borderColor)
        self.validateMargin()
    }
    
    func validateMargin() {
        let marginWidth = self.bounds.width * self.marginPercentage
        self.leftConstraint.constant = marginWidth
        self.rightConstraint.constant = marginWidth
        self.topConstraint.constant = marginWidth
        self.bottomConstraint.constant = marginWidth
        
        self.shortcutNameLabel.font = self.shortcutNameLabel.font.withSize(self.bounds.height - (marginWidth * 2))
    }
}

#if os(iOS) || os(tvOS)

import RxSwift
import UIKit

extension Reactive where Base: ProfileView {
    
    /// Bindable sink for `profileViewModel` property.
    internal var profileViewModel: Binder<ProfileViewModel?> {
        return Binder(self.base) { profileView, model in
            profileView.viewModel = model
        }
    }
    
}

#endif
