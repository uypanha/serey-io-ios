//
//  WalletViewModel.swift
//  SereyIO
//
//  Created by Panha Uy on 7/1/20.
//  Copyright © 2020 Phanha Uy. All rights reserved.
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
    }
    
    enum ViewToPresent {
        case transactionController(TransactionHistoryViewModel)
        case transferCoinController(TransferCoinViewModel)
        case receiveCoinController
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
    
    let transferService: TransferService
    let userService: UserService
    
    override init() {
        self.didActionSubject = .init()
        self.shouldPresentSubject = .init()
        
        self.userInfo = .init(value: AuthData.shared.loggedUserModel)
        self.cells = .init(value: [])
        self.walletCells = .init(value: [])
        self.wallets = .init(value: [.coin(coins: nil), .power(power: nil)])
        self.menu = .init(value: WalletMenu.menuItems)
        
        self.transferService = .init()
        self.userService = .init()
        super.init()
        
        setUpRxObservers()
    }
}

// MARK: - Networks
extension WalletViewModel {
    
    func initialNetworkConnection() {
        initTransaction()
        fetchProfile()
    }
    
    private func initTransaction() {
        self.transferService.initTransaction()
            .subscribe(onNext: { [weak self] data in
                self?.transferService.publicKey = data.publicKey
                self?.transferService.trxId = data.trxId
            }, onError: { [weak self] error in
                let errorInfo = ErrorHelper.prepareError(error: error)
                self?.shouldPresentError(errorInfo)
            }) ~ self.disposeBag
    }
    
    private func claimReward() {
        self.transferService.claimReward()
            .subscribe(onNext: { data in
                print(data.message)
            }, onError: { [weak self] error in
                let errorInfo = ErrorHelper.prepareError(error: error)
                self?.shouldPresentError(errorInfo)
            }) ~ self.disposeBag
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
        return menuItems.map { WalletMenuCellViewModel($0) }
    }
}

// MARK: - Action Handlers
fileprivate extension WalletViewModel {
    
    func handleItemSelected(_ indexPath: IndexPath) {
        if let item = self.item(at: indexPath) as? WalletMenuCellViewModel {
            switch item.menu.value {
            case .sendCoin:
                let transferCoinViewModel = TransferCoinViewModel()
                self.shouldPresent(.transferCoinController(transferCoinViewModel))
            case .receiveCoin:
                self.shouldPresent(.receiveCoinController)
            default:
                break
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
                let coin = WalletType.coin(coins: userModel?.balance.replacingOccurrences(of: "SEREY", with: ""))
                let power = WalletType.power(power: userModel?.sereypower.replacingOccurrences(of: "SEREY", with: ""))
                self.wallets.accept([coin, power])
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
                }
            }) ~ self.disposeBag
    }
    
    private func setUpUserInfoObservers(_ userInfo: UserModel) {
        
        Observable.from(object: userInfo)
            .asObservable()
            .subscribe(onNext: { [unowned self] userModel in
                let coin = WalletType.coin(coins: userModel.balance.replacingOccurrences(of: "SEREY", with: ""))
                let power = WalletType.power(power: userModel.sereypower.replacingOccurrences(of: "SEREY", with: ""))
                self.wallets.accept([coin, power])
            }).disposed(by: self.disposeBag)
    }
}