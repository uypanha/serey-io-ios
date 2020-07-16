//
//  BoardFeatureView.swift
//  Togness
//
//  Created by Phanha Uy on 1/2/20.
//  Copyright © 2020 Phanha Uy. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxBinding
import Kingfisher
import RxKingfisher

class BoardFeatureView: NibView {
    
    @IBOutlet weak var featureImageView: UIImageView!
    @IBOutlet weak var headlineLabel: UILabel!
    @IBOutlet weak var messageLabel: UILabel!
    
    var viewModel: BoardFeatureViewModel? {
        didSet {
            guard let viewModel = self.viewModel else { return }
            
            self.disposeBag ~ [
                viewModel.image ~> self.featureImageView.rx.image,
                viewModel.title ~> self.headlineLabel.rx.text,
                viewModel.message ~> self.messageLabel.rx.text
            ]
        }
    }
}

#if os(iOS) || os(tvOS)

import RxSwift
import UIKit

extension Reactive where Base: BoardFeatureView {
    
    /// Bindable sink for `profileViewModel` property.
    internal var veiwModel: Binder<BoardFeatureViewModel?> {
        return Binder(self.base) { boardFeatureView, model in
            boardFeatureView.viewModel = model
        }
    }
}

#endif
