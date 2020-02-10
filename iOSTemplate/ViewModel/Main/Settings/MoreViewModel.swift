//
//  MoreViewModel.swift
//  iOSTemplate
//
//  Created by Phanha Uy on 2/10/20.
//  Copyright © 2020 Phanha Uy. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift

class MoreViewModel: BaseCellViewModel, DownloadStateNetworkProtocol, CollectionMultiSectionsProviderModel, ShouldReactToAction, ShouldPresent {
    
    enum Action {
        case itemSelected(IndexPath)
    }
    
    enum ViewToPresent {
        case languagesViewController
    }
    
    // input:
    lazy var didActionSubject = PublishSubject<Action>()
    
    // output:
    lazy var shouldPresentSubject = PublishSubject<ViewToPresent>()
    
    let cells: BehaviorRelay<[SectionItem]>
    let cellModels: BehaviorRelay<[SectionType: [CellViewModel]]>
    
    lazy var downloadDisposeBag: DisposeBag = DisposeBag()
    lazy var isDownloading = BehaviorRelay<Bool>(value: false)
    
    override init() {
        self.cells = BehaviorRelay(value: [])
        self.cellModels = BehaviorRelay(value: [:])
        super.init()
        
        setUpRxObservers()
        cellModels.accept(prepareCellModels())
        registerForNotifs()
    }
    
    deinit {
        unregisterFromNotifs()
    }
}

// MARK: - Networks
extension MoreViewModel {
    
    func initialDownloadData() {
        downloadData()
    }
    
    func downloadData() {
        if !self.isDownloading.value {
            self.isDownloading.accept(true)
        }
    }
}

// MARK: - Preparations & Tools
extension MoreViewModel {
    
    enum SectionType {
        case signIn
        case profile
        case general
        case about
        
        var title: String? {
            switch self {
            case .general:
                return "General"
            case .about:
                return "About"
            default:
                return nil
            }
        }
    }
    
    fileprivate func prepareCellModels() -> [SectionType: [CellViewModel]] {
        var sectionItems: [SectionType: [CellViewModel]] = [:]
        
        sectionItems[.general] = [SettingCellViewModel(.lagnauge), SettingCellViewModel(.notificationSettings, true)]
        sectionItems[.about] = [SettingCellViewModel(.sereyApps), SettingCellViewModel(.version, true)]
        
        return sectionItems
    }
    
    fileprivate func prepareCells(_ cellModels: [SectionType: [CellViewModel]]) -> [SectionItem] {
        var sectionItems: [SectionItem] = []
        
        if let signInCells = cellModels[.signIn] {
            sectionItems.append(SectionItem(model: Section(header: SectionType.signIn.title), items: signInCells))
        }
        
        if let profileCells = cellModels[.profile] {
            sectionItems.append(SectionItem(model: Section(header: SectionType.profile.title), items: profileCells))
        }
        
        if let generalCells = cellModels[.general] {
            sectionItems.append(SectionItem(model: Section(header: SectionType.general.title), items: generalCells))
        }
        
        if let aboutCells = cellModels[.about] {
            sectionItems.append(SectionItem(model: Section(header: SectionType.about.title), items: aboutCells))
        }
        
        return sectionItems
    }
}

// MARK: - Action Handlers
fileprivate extension MoreViewModel {
    
    func handleItemSelected(_ indexPath: IndexPath) {
        if let item = item(at: indexPath) as? SettingCellViewModel {
            switch item.type.value {
            case .lagnauge:
                self.shouldPresent(.languagesViewController)
            default:
                break
            }
        }
    }
}

// MARK: - SetUp RxObservers
fileprivate extension MoreViewModel {
    
    func setUpRxObservers() {
        setUpContentChangedObservers()
        setUpActionObservers()
    }
    
    func setUpContentChangedObservers() {
        
        self.isDownloading.asObservable()
            .filter { $0 }
            .map { _ in self.prepareCellModels() }
            .bind(to: self.cellModels)
            .disposed(by: self.disposeBag)
        
        self.cellModels.asObservable()
            .map { self.prepareCells($0) }
            .bind(to: self.cells)
            .disposed(by: self.disposeBag)
    }
    
    func setUpActionObservers() {
        self.didActionSubject.asObservable()
            .subscribe(onNext: { [weak self] action in
                switch action {
                case .itemSelected(let indexPath):
                    self?.handleItemSelected(indexPath)
                }
            }).disposed(by: self.disposeBag)
    }
}

// MARK: - NotificationObserver
extension MoreViewModel: NotificationObserver {
    
    func notificationReceived(_ notification: Notification) {
        guard let appNotif = notification.appNotification else { return }
        switch appNotif {
        case .languageChanged:
            self.cellModels.accept(self.prepareCellModels())
        default:
            break
        }
    }
}

