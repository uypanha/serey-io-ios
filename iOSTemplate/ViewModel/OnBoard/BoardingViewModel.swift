//
//  BoardingViewModel.swift
//  iOSTemplate
//
//  Created by Phanha Uy on 2/1/20.
//  Copyright © 2020 Phanha Uy. All rights reserved.
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

    override init() {
        super.init()
        
        setUpRxObservers()
    }
}

// MARK: - Action Handlers
fileprivate extension BoardingViewModel {
    
    func handleBeginButtonPressed() {
//        FeatureStore.shared.areFeaturesIntroduced = true
        self.shouldPresent(.homeViewController)
    }
    
    func handleSkipButtonPressed() {
//        FeatureStore.shared.areFeaturesIntroduced = true
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
