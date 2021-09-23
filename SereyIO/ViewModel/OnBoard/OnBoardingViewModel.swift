//
//  OnBoardingViewModel.swift
//  SereyIO
//
//  Created by Panha Uy on 7/8/21.
//  Copyright © 2021 Serey IO. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift
import RxBinding

class OnBoardingViewModel: BaseViewModel, CollectionSingleSecitionProviderModel, ShouldReactToAction, ShouldPresent {
    
    enum Action {
        case nextPressed(Int)
        case skipPressed
        case onPageLeft(Int)
    }
    
    enum ViewToPresent {
        case moveToNextPage
        case mainViewController
    }
    
    // input:
    let didActionSubject: PublishSubject<Action>
    
    // output:
    let shouldPresentSubject: PublishSubject<ViewToPresent>
    
    let cells: BehaviorRelay<[CellViewModel]>
    let features: BehaviorRelay<[FeatureBoarding]>
    
    override init() {
        self.didActionSubject = .init()
        self.shouldPresentSubject = .init()
        
        self.cells = .init(value: [])
        self.features = .init(value: FeatureBoarding.featuresToIntroduce)
        super.init()
        
        setUpRxObservers()
        self.cells.accept(self.prepareCells(self.features.value))
    }
}

// MARK: - Preparations & Tools
extension OnBoardingViewModel {
    
    func prepareCells(_ features: [FeatureBoarding]) -> [CellViewModel] {
        return features.map { $0.viewModel }
    }
}

// MARK: - Action Handlers
fileprivate extension OnBoardingViewModel {
    
    func handleNextPressed(_ currentIndex: Int) {
        let feature = self.features.value[currentIndex]
        PreferenceStore.shared.setFeautureSeen(of: feature, seen: true)
        if currentIndex == self.features.value.count - 1 {
            self.shouldPresent(.mainViewController)
        } else {
            self.shouldPresent(.moveToNextPage)
        }
    }
    
    func handleSkipPressed() {
        self.features.value.forEach { feature in
            PreferenceStore.shared.setFeautureSeen(of: feature, seen: true)
        }
        self.shouldPresent(.mainViewController)
    }
}

// MARK: - SetUp RxObservers
extension OnBoardingViewModel {
    
    func setUpRxObservers() {
        self.setUpActionObservers()
    }
    
    func setUpActionObservers() {
        self.didActionSubject.asObservable()
            .subscribe(onNext: { [weak self] action in
                switch action {
                case .nextPressed(let currentIndex):
                    self?.handleNextPressed(currentIndex)
                case .skipPressed:
                    self?.handleSkipPressed()
                case .onPageLeft(let currentIndex):
                    if let feature = self?.features.value[currentIndex] {
                        PreferenceStore.shared.setFeautureSeen(of: feature, seen: true)
                    }
                }
            }) ~ self.disposeBag
    }
}
