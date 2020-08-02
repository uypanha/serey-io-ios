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
    }
    
    enum ViewToPresent {
        case transactionController
    }
    
    // input:
    let didActionSubject: PublishSubject<Action>
    
    // output:
    let shouldPresentSubject: PublishSubject<ViewToPresent>
    
    let walletCells: BehaviorRelay<[CellViewModel]>
    let cells: BehaviorRelay<[CellViewModel]>
    
    let wallets: BehaviorRelay<[WalletType]>
    let menu: BehaviorRelay<[WalletMenu]>
    
    let transferService: TransferService
    
    override init() {
        self.didActionSubject = .init()
        self.shouldPresentSubject = .init()
        
        self.cells = .init(value: [])
        self.walletCells = .init(value: [])
        self.wallets = .init(value: WalletType.allCases)
        self.menu = .init(value: WalletMenu.menuItems)
        self.transferService = .init()
        super.init()
        
        setUpRxObservers()
    }
}

// MARK: - Networks
extension WalletViewModel {
    
    func initTransaction() {
        self.transferService.initTransaction()
            .subscribe(onNext: { [weak self] data in
                self?.transferService.publicKey = data.publicKey
                self?.transferService.trxId = data.trxId
            }, onError: { [weak self] error in
                let errorInfo = ErrorHelper.prepareError(error: error)
                self?.shouldPresentError(errorInfo)
            }) ~ self.disposeBag
    }
    
    func claimReward() {
        self.transferService.claimReward()
            .subscribe(onNext: { data in
                print(data.message)
            }, onError: { [weak self] error in
                let errorInfo = ErrorHelper.prepareError(error: error)
                self?.shouldPresentError(errorInfo)
            }) ~ self.disposeBag
    }
}

// MARK: - Preparations & Tools
extension WalletViewModel {
    
    enum WalletType: CaseIterable {
        case coin
        case power
        
        var title: String {
            switch self {
            case .coin:
                return "SEREY COIN"
            case .power:
                return "SEREY POWER"
            }
        }
        
        var cardColor: UIColor? {
            switch self {
            case .coin:
                return UIColor(hexString: "2F3C4D")
            case .power:
                return UIColor(hexString: "FACB57")
            }
        }
    }
    
    func prepareWalletCells(_ types: [WalletType]) -> [CellViewModel] {
        return types.map { WalletCardCellViewModel($0) }
    }
    
    func prepareMenuCells(_ menuItems: [WalletMenu]) -> [CellViewModel] {
        return menuItems.map { WalletMenuCellViewModel($0) }
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
    }
    
    func setUpActionObservers() {
        self.didActionSubject.asObservable()
            .subscribe(onNext: { [weak self] action in
                switch action {
                case .transactionPressed:
                    self?.shouldPresent(.transactionController)
                }
            }) ~ self.disposeBag
    }
}
