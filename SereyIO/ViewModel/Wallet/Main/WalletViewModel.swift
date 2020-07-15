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

class WalletViewModel: BaseCellViewModel, CollectionSingleSecitionProviderModel {
    
    let cells: BehaviorRelay<[CellViewModel]>
    let wallets: BehaviorRelay<[WalletType]>
    
    let ownerKey: String = "P5Kac8enBjVAnRGYMY1LK8xJu9AhZ6u3GWua57gytSebG4SQMgvb"
    
    override init() {
        self.cells = .init(value: [])
        self.wallets = .init(value: WalletType.allCases)
        super.init()
        
        setUpRxObservers()
        _ = generateKeys("panhauy", key: ownerKey)
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
    
    private func generateKeys(_ username: String, key: String) -> [String] {
        if let ownerKey = PrivateKey(key) {
            return (0...3).map { _ in ownerKey.createPublic(prefix: .custom("SRY")).address }
        } else {
            return ["owner", "active", "posting", "memo"].map { role in
                let key = PrivateKey(seed: "\(username)\(role)\(key)")?.wif ?? ""
//                    .createPublic(prefix: .custom("SRY")).address ?? ""
                print("\(role) Key =======> \(key)")
                return key
            }
        }
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
