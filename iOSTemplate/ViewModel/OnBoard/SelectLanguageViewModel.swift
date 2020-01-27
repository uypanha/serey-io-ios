//
//  SelectLanguageViewModel.swift
//  iOSTemplate
//
//  Created by Phanha Uy on 1/27/20.
//  Copyright © 2020 Phanha Uy. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift
import RxBinding

class SelectLanguageViewModel: BaseViewModel, ShouldReactToAction, ShouldPresent {
    
    enum Action {
        case languageSelected(Languages)
    }
    
    enum ViewToPresent {
        case boardingViewController
    }
    
    // input:
    lazy var didActionSubject = PublishSubject<Action>()
    
    // output:
    internal lazy var shouldPresentSubject = PublishSubject<ViewToPresent>()
    
    override init() {
        super.init()
        
        setUpRxObservers()
    }
}

// MARK: - Action Handlers
fileprivate extension SelectLanguageViewModel {
    
    func handleLanguageSelected(_ language: Languages) {
        LanguageManger.shared.setLanguage(language: language)
        self.shouldPresent(.boardingViewController)
    }
}

// MARK: - SetUp RxObservers
fileprivate extension SelectLanguageViewModel {
    
    func setUpRxObservers() {
        setUpActionObservers()
    }
    
    func setUpActionObservers() {
        self.didActionSubject.asObservable()
            .subscribe(onNext: { [weak self] action in
                switch action {
                case .languageSelected(let language):
                    self?.handleLanguageSelected(language)
                }
            }) ~ self.disposeBag
    }
}
