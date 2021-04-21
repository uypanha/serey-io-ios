//
//  MoreViewModel.swift
//  SereyIO
//
//  Created by Phanha Uy on 2/10/20.
//  Copyright © 2020 Serey IO. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift
import RxBinding
import RxRealm
import Then

class MoreViewModel: BaseCellViewModel, DownloadStateNetworkProtocol, CollectionMultiSectionsProviderModel, ShouldReactToAction, ShouldPresent {
    
    enum Action {
        case itemSelected(IndexPath)
        case privacyPressed
        case termsPressed
        case signOutPressed
        case signOutConfirmed
    }
    
    enum ViewToPresent {
        case signInController
        case accountViewController(UserAccountViewModel)
        case moreAppsController(MoreAppsViewModel)
        case languagesViewController
        case notificationSettingsController
        case webViewController(WebViewViewModel)
        case walletViewController
        case signOutDialog
    }
    
    // input:
    lazy var didActionSubject = PublishSubject<Action>()
    
    // output:
    lazy var shouldPresentSubject = PublishSubject<ViewToPresent>()
    
    let userInfo: BehaviorRelay<UserModel?>
    let cells: BehaviorRelay<[SectionItem]>
    let cellModels: BehaviorRelay<[SectionType: [CellViewModel]]>
    
    var userService: UserService
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
        guard let username = AuthData.shared.username else { return }
        
        if AuthData.shared.isUserLoggedIn && !self.isDownloading.value {
            self.isDownloading.accept(true)
            self.fetchProfile(username)
        }
    }
    
    fileprivate func fetchProfile(_ username: String) {
        self.userService.fetchProfile(username)
            .subscribe(onNext: { [weak self] response in
                response.data.result.save()
                if self?.userInfo.value == nil {
                    self?.userInfo.accept(response.data.result)
                }
            }, onError: { [weak self] error in
                let errorInfo = ErrorHelper.prepareError(error: error)
                self?.shouldPresentError(errorInfo)
            }) ~ self.disposeBag
    }
    
    fileprivate func signOutRequest() {
    }
}

// MARK: - Preparations & Tools
extension MoreViewModel {
    
    enum SectionType: CaseIterable {
        case signIn
        case profile
        case general
        case about
        case signOut
        
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
            if Constants.includeWallet {
                sectionItems[.profile] = [ProfileCellViewModel(self.userInfo.value), SettingCellViewModel(.myWallet, true)]
            } else {
                sectionItems[.profile] = [ProfileCellViewModel(self.userInfo.value, true)]
            }
        } else {
            let signInCellViewModel = SignInCellViewModel().then { [weak self] in self?.setUpSignInCellViewModelObservers($0) }
            #if DEVELOPMENT
                let walletCellViewModel = SettingCellViewModel(.myWallet, true)
                sectionItems[.signIn] = [signInCellViewModel, walletCellViewModel]
            #else
                sectionItems[.signIn] = [signInCellViewModel]
            #endif
        }
        sectionItems[.general] = [SettingCellViewModel(.lagnauge), SettingCellViewModel(.notificationSettings, true)]
        sectionItems[.about] = [
//            SettingCellViewModel(.sereyApps),
            SettingCellViewModel(.version, true)
        ]
        
        if AuthData.shared.isUserLoggedIn {
            let signOutButtonProperties = ButtonProperties().then {
                $0.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
                $0.textColor = ColorName.primaryRed.color
                $0.borderColor = ColorName.primaryRed.color
                $0.isCircular = false
            }
            let signOutButtonModel = ButtonCellViewModel(R.string.auth.signOut.localized(), signOutButtonProperties).then { [unowned self] in
                $0.shouldFireButtonAction
                    .map { Action.signOutPressed }
                    .bind(to: self.didActionSubject)
                    .disposed(by: $0.disposeBag)
            }
            sectionItems[.signOut] = [signOutButtonModel]
        }
        
        return sectionItems
    }
    
    fileprivate func prepareCells(_ cellModels: [SectionType: [CellViewModel]]) -> [SectionItem] {
        var sectionItems: [SectionItem] = []
        
        SectionType.allCases.forEach { type in
            if let cells = cellModels[type] {
                sectionItems.append(SectionItem(model: Section(header: type.title), items: cells))
            }
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
            case .sereyApps:
                let moreAppsViewModel = MoreAppsViewModel()
                self.shouldPresent(.moreAppsController(moreAppsViewModel))
            case .notificationSettings:
                self.shouldPresent(.notificationSettingsController)
            case .myWallet:
                self.shouldPresent(.walletViewController)
            default:
                break
            }
        } else if let item = item(at: indexPath) as? ProfileCellViewModel, let user = item.userInfo.value {
            let accountViewModel = UserAccountViewModel(user)
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
        
        self.userInfo.asObservable()
            .`do`(onNext: { [weak self] userModel in
                if let userModel = userModel {
                    self?.setUpUserInfoObservers(userModel)
                }
            }).subscribe(onNext: { [unowned self] userModel in
                self.cellModels.accept(self.prepareCellModels())
            }).disposed(by: self.disposeBag)
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
                case .signOutPressed:
                    self?.shouldPresent(.signOutDialog)
                case .signOutConfirmed:
                    AuthData.shared.removeAuthData()
                }
            }).disposed(by: self.disposeBag)
    }
    
    func setUpSignInCellViewModelObservers(_ cellModel: SignInCellViewModel) {
        cellModel.shouldSignIn.asObservable()
            .map { ViewToPresent.signInController }
            .bind(to: self.shouldPresentSubject)
            .disposed(by: cellModel.disposeBag)
    }
    
    private func setUpUserInfoObservers(_ userInfo: UserModel) {
        
        Observable.from(object: userInfo)
            .asObservable()
            .subscribe(onNext: { [unowned self] userModel in
                self.cellModels.accept(self.prepareCellModels())
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
        case .userDidLogin, .userDidLogOut:
            self.userService = UserService()
            self.userInfo.accept(AuthData.shared.loggedUserModel)
        default:
            break
        }
    }
}

