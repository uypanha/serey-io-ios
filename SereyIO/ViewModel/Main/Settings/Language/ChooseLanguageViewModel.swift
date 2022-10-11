//
//  ChooseLanguageViewModel.swift
//  SereyIO
//
//  Created by Phanha Uy on 1/30/20.
//  Copyright © 2020 Serey IO. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

class ChooseLanguageViewModel: BaseCellViewModel, CollectionMultiSectionsProviderModel, ShouldPresent {
    
    enum Action {
        case itemSelected(at: IndexPath)
    }
    
    enum ViewToPresent {
        case dismiss
    }
    
    // input:
    lazy var didActionSubject = PublishSubject<Action>()
    
    // output:
    lazy var shouldPresentSubject = PublishSubject<ViewToPresent>()
    
    var cells: BehaviorRelay<[SectionItem]>
    
    override init() {
        self.cells = BehaviorRelay(value: [])
        super.init()
        
        setUpRxObservers()
        prepareCells()
    }
}

// MAKR: - Preparations & Tools
fileprivate extension ChooseLanguageViewModel {
    
    func prepareCells() {
        let languages = LanguageManger.shared.supportedLanguages
        self.cells.accept([SectionItem(model: Section(), items: languages.map { LanguageCellViewModel(language: $0, false) })])
    }
}

// MARK: - Actions Handlers
fileprivate extension ChooseLanguageViewModel {
    
    func handleItemSelected(at indexPath: IndexPath) {
        if let cellModel = item(at: indexPath) as? LanguageCellViewModel {
            LanguageManger.shared.setLanguage(language: cellModel.language)
            self.shouldPresentSubject.onNext(.dismiss)
        }
    }
}

// MARK: - SetUp RxObservers
fileprivate extension ChooseLanguageViewModel {
    
    func setUpRxObservers() {
        setUpActionObserveres()
    }
    
    func setUpActionObserveres() {
        self.didActionSubject.asObservable()
            .subscribe(onNext: { [weak self] action in
                switch action {
                case .itemSelected(let indexPath):
                    self?.handleItemSelected(at: indexPath)
                }
            }).disposed(by: self.disposeBag)
    }
}
