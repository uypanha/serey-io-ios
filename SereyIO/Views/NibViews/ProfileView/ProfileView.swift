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
import Kingfisher
import RxKingfisher

class ProfileView: NibView {

    @IBOutlet weak var profileImageView: UIImageView!
    
    @IBInspectable var borderWidth: CGFloat = 1
    @IBInspectable var borderColor: UIColor = UIColor.lightGray.withAlphaComponent(0.2)
    
    var viewModel: ProfileViewModel? {
        didSet {
            guard let viewModel = self.viewModel else { return }
            
            viewModel.imageURL.asObservable()
                .map { $0 }
                .bind(to: self.profileImageView.kf.rx.image(placeholder: ViewUtiliesHelper.prepareDefualtPlaceholder(), options: [.processor(ResizingImageProcessor(referenceSize: CGSize(width: 500, height: 500), mode: .aspectFill))]))
                .disposed(by: self.disposeBag)
        }
    }
    
    override func styleUI() {
        super.styleUI()
    
        self.makeMeCircular()
        self.setBorder(borderWith: borderWidth, borderColor: borderColor)
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
