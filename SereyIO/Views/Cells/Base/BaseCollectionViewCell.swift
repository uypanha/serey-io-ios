//
//  BaseCollectionViewCell.swift
//  SereyIO
//
//  Created by Phanha Uy on 2/18/20.
//  Copyright © 2020 Phanha Uy. All rights reserved.
//

import UIKit
import RxSwift

class BaseCollectionViewCell: UICollectionViewCell {
    
    lazy var disposeBag: DisposeBag = {
        return DisposeBag()
    }()
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.disposeBag = DisposeBag()
    }
}
