//
//  BoardFeatureViewModel.swift
//  SereyIO
//
//  Created by Phanha Uy on 2/3/20.
//  Copyright © 2020 Serey IO. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift
import RxBinding

class BoardFeatureViewModel: CellViewModel {
    
    let feature: BehaviorRelay<FeatureBoarding>
    let image: BehaviorSubject<UIImage?>
    let title: BehaviorSubject<String?>
    let message: BehaviorSubject<String?>
    
    init(_ feature: FeatureBoarding) {
        self.feature = BehaviorRelay(value: feature)
        self.image = BehaviorSubject(value: nil)
        self.title = BehaviorSubject(value: nil)
        self.message = BehaviorSubject(value: nil)
        super.init()
        
        setUpRxObservers()
    }
    
}

// MARK: - Preparations & Tools
extension BoardFeatureViewModel {
    
    func notifyDataChanged(_ data: FeatureBoarding) {
        self.image.onNext(data.image)
        self.title.onNext(data.title)
        self.message.onNext(data.message)
    }
}

// MARK: - SetUp RxObservers
extension BoardFeatureViewModel {
    
    func setUpRxObservers() {
        self.feature.asObservable()
            .subscribe(onNext: { [weak self] feature in
                self?.notifyDataChanged(feature)
            }) ~ self.disposeBag
    }
}
