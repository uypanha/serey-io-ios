//
//  MoreViewModel.swift
//  SereyIO
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
        case privacyPressed
        case termsPressed
    }
    
    enum ViewToPresent {
        case signInController
        case accountViewController(AccountViewModel)
        case languagesViewController
        case webViewController(WebViewViewModel)
    }
    
    // input:
    lazy var didActionSubject = PublishSubject<Action>()
    
    // output:
    lazy var shouldPresentSubject = PublishSubject<ViewToPresent>()
    
    let userInfo: BehaviorRelay<UserModel?>
    let cells: BehaviorRelay<[SectionItem]>
    let cellModels: BehaviorRelay<[SectionType: [CellViewModel]]>
    
    let userService: UserService
    lazy var downloadDisposeBag: DisposeBag = DisposeBag()
    lazy var isDownloading = BehaviorRelay<Bool>(value: false)
    
    override init() {
        self.userInfo = BehaviorRelay(value: AuthData.shared.loggedUserModel)
        self.cells = BehaviorRelay(value: [])
        self.cellModels = BehaviorRelay(value: [:])
        self.userService = UserService()
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
    
    func downloadData() {
        if AuthData.shared.isUserLoggedIn && !self.isDownloading.value {
            self.isDownloading.accept(true)
            self.fetchProfile()
        }
    }
    
    fileprivate func fetchProfile() {
        
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
                return R.string.settings.general.localized()
            case .about:
                return R.string.settings.about.localized()
            default:
                return nil
            }
        }
    }
    
    fileprivate func prepareCellModels() -> [SectionType: [CellViewModel]] {
        var sectionItems: [SectionType: [CellViewModel]] = [:]
        
        if AuthData.shared.isUserLoggedIn {
            sectionItems[.profile] = [ProfileCellViewModel(), SettingCellViewModel(.myWallet, true)]
        } else {
            sectionItems[.profile] = [SignInCellViewModel().then { [weak self] in self?.setUpSignInCellViewModelObservers($0) }]
        }
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
        } else if let _ = item(at: indexPath) as? ProfileCellViewModel {
            let accountViewModel = AccountViewModel("")
            self.shouldPresent(.accountViewController(accountViewModel))
        }
    }
    
    func handleOpenWebView(_ title: String, url: URL?) {
        let webViewViewModel = WebViewViewModel(withURLToLoad: url, title: title)
        self.shouldPresent(.webViewController(webViewViewModel))
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
                case .privacyPressed:
                    self?.handleOpenWebView("Privacy Policy", url: Constants.privacyAndPolicyUrl)
                case .termsPressed:
                    self?.handleOpenWebView("Terms of Service", url: Constants.termAndConditionsUrl)
                }
            }).disposed(by: self.disposeBag)
    }
    
    func setUpSignInCellViewModelObservers(_ cellModel: SignInCellViewModel) {
        cellModel.shouldSignIn.asObservable()
            .map { ViewToPresent.signInController }
            .bind(to: self.shouldPresentSubject)
            .disposed(by: cellModel.disposeBag)
    }
}

// MARK: - NotificationObserver
extension MoreViewModel: NotificationObserver {
    
    func notificationReceived(_ notification: Notification) {
        guard let appNotif = notification.appNotification else { return }
        switch appNotif {
        case .languageChanged:
            self.cellModels.accept(self.prepareCellModels())
        case .userDidLogin, .userDidLogOut:
            self.userInfo.accept(AuthData.shared.loggedUserModel)
            self.cellModels.accept(self.prepareCellModels())
        }
    }
}

