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

class WalletViewModel: BaseCellViewModel, CollectionSingleSecitionProviderModel {
    
    let cells: BehaviorRelay<[CellViewModel]>
    let wallets: BehaviorRelay<[WalletType]>
    
    override init() {
        self.cells = .init(value: [])
        self.wallets = .init(value: WalletType.allCases)
        super.init()
        
        setUpRxObservers()
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
}

// MARK: - SetUp RxObservers
extension WalletViewModel {
    
    func setUpRxObservers() {
        setUpContentChangedObservers()
    }
    
    func setUpContentChangedObservers() {
        self.wallets.asObservable()
            .map { self.prepareWalletCells($0) }
            ~> self.cells
            ~ self.disposeBag
    }
}
