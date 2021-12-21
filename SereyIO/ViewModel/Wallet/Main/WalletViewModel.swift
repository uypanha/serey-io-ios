//
//  WalletViewModel.swift
//  SereyIO
//
//  Created by Panha Uy on 7/1/20.
//  Copyright © 2020 Serey IO. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift
import RxBinding
import Steem

class WalletViewModel: BaseCellViewModel, CollectionSingleSecitionProviderModel, ShouldReactToAction, ShouldPresent {
    
    enum Action {
        case transactionPressed
        case itemSelected(IndexPath)
        case settingsPressed
    }
    
    enum ViewToPresent {
        case transactionController(TransactionHistoryViewModel)
        case transferCoinController(TransferCoinViewModel)
        case receiveCoinController(ReceiveCoinViewModel)
        case scanQRViewController(PayQRViewModel)
        case powerUpController(PowerUpViewModel)
        case powerDownController(PowerDownViewModel)
        case claimRewardController(ClaimRewardViewModel)
        case cancelPowerDownController(CancelPowerDownViewModel)
        case delegatePowerController(DelegatePowerViewModel)
        case settingsController
    }
    
    // input:
    let didActionSubject: PublishSubject<Action>
    
    // output:
    let shouldPresentSubject: PublishSubject<ViewToPresent>
    
    let userInfo: BehaviorRelay<UserModel?>
    let walletCells: BehaviorRelay<[CellViewModel]>
    let cells: BehaviorRelay<[CellViewModel]>
    
    let wallets: BehaviorRelay<[WalletType]>
    let menu: BehaviorRelay<[WalletMenu]>
    
    let userService: UserService
    
    override init() {
        self.didActionSubject = .init()
        self.shouldPresentSubject = .init()
        
        self.userInfo = .init(value: AuthData.shared.loggedUserModel)
        self.cells = .init(value: [])
        self.walletCells = .init(value: [])
        self.wallets = .init(value: [.coin(coins: nil, usd: nil), .power(power: nil)])
        self.menu = .init(value: WalletMenu.menuItems)
        
        self.userService = .init()
        super.init()
        
        setUpRxObservers()
    }
}

// MARK: - Networks
extension WalletViewModel {
    
    func initialNetworkConnection() {
        fetchProfile()
    }
    
    private func fetchProfile() {
        if let username = AuthData.shared.username {
            self.userService.fetchProfile(username)
                .subscribe(onNext: { [weak self] data in
                    data.data.result.save()
                    if self?.userInfo.value == nil {
                        self?.userInfo.accept(data.data.result)
                    }
                }) ~ self.disposeBag
        }
    }
}

// MARK: - Preparations & Tools
extension WalletViewModel {
    
    func prepareWalletCells(_ types: [WalletType]) -> [CellViewModel] {
        return types.map { $0.value != nil ? WalletCardCellViewModel($0) : WalletCardCellViewModel(true) }
    }
    
    func prepareMenuCells(_ menuItems: [WalletMenu]) -> [CellViewModel] {
        return menuItems.map { menu in
            var isEnabled = true
            if menu == .claimReward { isEnabled = self.userInfo.value?.isClaimReward ?? true }
            return WalletMenuCellViewModel(menu, isEnabled: isEnabled)
        }
    }
}

// MARK: - Action Handlers
fileprivate extension WalletViewModel {
    
    func handleItemSelected(_ indexPath: IndexPath) {
        if let item = self.item(at: indexPath) as? WalletMenuCellViewModel {
            switch item.menu.value {
            case .sendCoin:
                let transferCoinViewModel = TransferCoinViewModel()
                self.setUpTransactionObserers(transferCoinViewModel)
                self.shouldPresent(.transferCoinController(transferCoinViewModel))
            case .receiveCoin:
                guard let username = AuthData.shared.username else { return }
                let viewModel = ReceiveCoinViewModel(username)
                self.shouldPresent(.receiveCoinController(viewModel))
            case .pay:
                let payQRViewModel = PayQRViewModel().then { self.setUpPayQRObservers($0) }
                self.shouldPresent(.scanQRViewController(payQRViewModel))
            case .powerUp:
                let powerUpViewModel = PowerUpViewModel()
                self.setUpTransactionObserers(powerUpViewModel)
                self.shouldPresent(.powerUpController(powerUpViewModel))
            case .powerDown:
                let powerDownViewModel = PowerDownViewModel()
                self.setUpTransactionObserers(powerDownViewModel)
                self.shouldPresent(.powerDownController(powerDownViewModel))
            case .claimReward:
                if self.userInfo.value?.isClaimReward == true {
                    let claimRewardViewModel = ClaimRewardViewModel()
                    self.setUpTransactionObserers(claimRewardViewModel)
                    self.shouldPresent(.claimRewardController(claimRewardViewModel))
                }
            case .delegatePower:
                let delegatePowerViewModel = DelegatePowerViewModel()
                self.setUpTransactionObserers(delegatePowerViewModel)
                self.shouldPresent(.delegatePowerController(delegatePowerViewModel))
            case .cancelDelegate:
                let delegatePowerViewModel = DelegatePowerViewModel(.cancelDelegate)
                self.setUpTransactionObserers(delegatePowerViewModel)
                self.shouldPresent(.delegatePowerController(delegatePowerViewModel))
            case .cancelPower:
                let cancelPowerDownViewModel = CancelPowerDownViewModel()
                self.setUpTransactionObserers(cancelPowerDownViewModel)
                self.shouldPresent(.cancelPowerDownController(cancelPowerDownViewModel))
            }
        }
    }
    
    func handleTransactionPressed() {
        let transactionHistoryViewModel = TransactionHistoryViewModel()
        self.shouldPresent(.transactionController(transactionHistoryViewModel))
    }
}

// MARK: - SetUp RxObservers
extension WalletViewModel {
    
    func setUpRxObservers() {
        setUpContentChangedObservers()
        setUpActionObservers()
    }
    
    func setUpContentChangedObservers() {
        self.wallets.asObservable()
            .map { self.prepareWalletCells($0) }
            ~> self.walletCells
            ~ self.disposeBag
        
        self.menu.asObservable()
            .map { self.prepareMenuCells($0) }
            ~> self.cells
            ~ self.disposeBag
        
        self.userInfo.asObservable()
            .`do`(onNext: { [weak self] userModel in
                if let userModel = userModel {
                    self?.setUpUserInfoObservers(userModel)
                }
            }).subscribe(onNext: { [unowned self] userModel in
                let usdPrice = userModel?.usdPrice ?? ""
                let coin = WalletType.coin(coins: userModel?.balance.replacingOccurrences(of: "SEREY", with: ""), usd: "≃ $\(usdPrice)")
                let power = WalletType.power(power: userModel?.sereypower.replacingOccurrences(of: "SEREY", with: ""))
                self.wallets.accept([coin, power])
                self.menu.accept(WalletMenu.menuItems)
            }).disposed(by: self.disposeBag)
    }
    
    func setUpActionObservers() {
        self.didActionSubject.asObservable()
            .subscribe(onNext: { [weak self] action in
                switch action {
                case .transactionPressed:
                    self?.handleTransactionPressed()
                case .itemSelected(let indexPath):
                    self?.handleItemSelected(indexPath)
                case .settingsPressed:
                    self?.shouldPresent(.settingsController)
                }
            }) ~ self.disposeBag
    }
    
    private func setUpUserInfoObservers(_ userInfo: UserModel) {
        
        Observable.from(object: userInfo)
            .asObservable()
            .subscribe(onNext: { [unowned self] userModel in
                let usdPrice = userModel.usdPrice ?? ""
                let coin = WalletType.coin(coins: userModel.balance.replacingOccurrences(of: "SEREY", with: ""), usd: "≃ $\(usdPrice)")
                let power = WalletType.power(power: userModel.sereypower.replacingOccurrences(of: "SEREY", with: ""))
                self.wallets.accept([coin, power])
            }).disposed(by: self.disposeBag)
    }
    
    private func setUpPayQRObservers(_ payQrViewModel: PayQRViewModel) {
        payQrViewModel.didUsernameFound
            .subscribe(onNext: { [weak self] username in
                let transferCoinViewModel = TransferCoinViewModel(username)
                self?.setUpTransactionObserers(transferCoinViewModel)
                self?.shouldPresent(.transferCoinController(transferCoinViewModel))
            }).disposed(by: payQrViewModel.disposeBag)
    }
    
    private func setUpTransactionObserers(_ viewModel: BaseInitTransactionViewModel) {
        viewModel.didTransactionUpdate
            .subscribe(onNext: { [weak self] _ in
                self?.fetchProfile()
            }) ~ self.disposeBag
    }
}
