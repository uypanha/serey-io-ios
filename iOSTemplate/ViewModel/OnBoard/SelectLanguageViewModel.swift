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

class SelectLanguageViewModel: BaseViewModel, ShouldReactToAction, ShouldPresent, CollectionSingleSecitionProviderModel {
    
    enum Action {
        case itemSelected(IndexPath)
    }
    
    enum ViewToPresent {
        case languagesBottomSheetController
        case boardingViewController
    }
    
    // input:
    lazy var didActionSubject = PublishSubject<Action>()
    
    // output:
    internal lazy var shouldPresentSubject = PublishSubject<ViewToPresent>()
    
    let cells: BehaviorRelay<[CellViewModel]>
    
    override init() {
        self.cells = BehaviorRelay(value: [])
        super.init()
        
        setUpRxObservers()
        registerForNotifs()
        self.cells.accept(self.prepareCells())
    }
    
    deinit {
        unregisterFromNotifs()
    }
}

// MARK: - Preparations & Tools
extension SelectLanguageViewModel {
    
    private func prepareCells() -> [CellViewModel] {
        return [LanguageCellViewModel(language: LanguageManger.shared.currentLanguage, true)]
    }
}

// MARK: - Action Handlers
fileprivate extension SelectLanguageViewModel {
    
    func handleItemSelected(_ indexPath: IndexPath) {
        if let _ = item(at: indexPath) as? LanguageCellViewModel {
            self.shouldPresent(.languagesBottomSheetController)
        }
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
                case .itemSelected(let indexPath):
                    self?.handleItemSelected(indexPath)
                }
            }) ~ self.disposeBag
    }
}

// MARK: - NotificationObserver
extension SelectLanguageViewModel: NotificationObserver {

    func notificationReceived(_ notification: Notification) {
        guard let appNotif = notification.appNotification else { return }
        switch appNotif {
        case .languageChanged:
            self.cells.accept(self.prepareCells())
        default:
            break
        }
    }
}
