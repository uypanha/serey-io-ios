//
//  BoardingViewModel.swift
//  SereyIO
//
//  Created by Phanha Uy on 2/1/20.
//  Copyright © 2020 Serey IO. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift
import RxBinding

class BoardingViewModel: BaseViewModel, ShouldReactToAction, ShouldPresent {

    enum Action {
        case beginButtonPressed
        case skipPressed
    }
    
    enum ViewToPresent {
        case homeViewController
    }
    
    // input:
    lazy var didActionSubject = PublishSubject<Action>()
    
    // output:
    internal lazy var shouldPresentSubject = PublishSubject<BoardingViewModel.ViewToPresent>()
    let slideCellModels: BehaviorRelay<[CellViewModel]>

    override init() {
        self.slideCellModels = BehaviorRelay(value: [])
        super.init()
        
        setUpRxObservers()
        self.slideCellModels.accept(prepareSlides())
    }
}

// MARK: - Preparations & Tools
extension BoardingViewModel {
    
    func prepareSlides() -> [CellViewModel] {
        return (FeatureBoarding.allCases).map { BoardFeatureViewModel($0) }
    }
}

// MARK: - Action Handlers
fileprivate extension BoardingViewModel {
    
    func handleBeginButtonPressed() {
        FeatureStore.shared.areFeaturesIntroduced = true
        self.shouldPresent(.homeViewController)
    }
    
    func handleSkipButtonPressed() {
        FeatureStore.shared.areFeaturesIntroduced = true
        self.shouldPresent(.homeViewController)
    }
}

// MARK: - SetUp RxObservers
fileprivate extension BoardingViewModel {
    
    func setUpRxObservers() {
        setUpActionObservers()
    }
    
    func setUpActionObservers() {
        self.didActionSubject.asObservable()
            .subscribe(onNext: { [weak self] action in
                switch action {
                case .beginButtonPressed:
                    self?.handleBeginButtonPressed()
                case .skipPressed:
                    self?.handleSkipButtonPressed()
                }
            }) ~ self.disposeBag
    }
}
