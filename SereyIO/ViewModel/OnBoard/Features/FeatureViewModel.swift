//
//  FeatureViewModel.swift
//  SereyIO
//
//  Created by Panha Uy on 7/8/21.
//  Copyright © 2021 Serey IO. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift
import RxBinding

class FeatureViewModel: CellViewModel {
    
    let feature: BehaviorRelay<FeatureBoarding>
    let image: BehaviorSubject<UIImage?>
    let title: BehaviorSubject<String?>
    let message: BehaviorSubject<String?>
    
    init(_ feature: FeatureBoarding) {
        self.feature = .init(value: feature)
        self.image = .init(value: feature.image)
        self.title = .init(value: feature.title)
        self.message = .init(value: feature.message)
        super.init()
    }
}
