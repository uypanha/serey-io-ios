//
//  CoinPriceManager.swift
//  SereyIO
//
//  Created by Mäd on 20/12/2021.
//  Copyright © 2021 Serey IO. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift
import RxBinding
import RxRealm

class CoinPriceManager: NSObject {
    
    /// Returns the singleton CoinPriceManager instance.
    static let shared: CoinPriceManager = CoinPriceManager()
    
    var disposeBag: DisposeBag
    let coinService: CoinService
    
    let sereyTicker: BehaviorRelay<TickerModel?>
    let sereyPrice: BehaviorRelay<Double>
    
    static func configure() {
        loadTicker()
    }
    
    static func loadTicker() {
        CoinPriceManager.shared.fetchTicker()
    }
    
    override init() {
        self.coinService = .init()
        self.disposeBag = .init()
        self.sereyTicker = .init(value: TickerModel().qeuryFirst())
        self.sereyPrice = .init(value: 0)
        super.init()
        
        setUpRxObservers()
        setUpTickerDataChanged()
    }
    
    func setUpRxObservers() {
        self.sereyTicker.asObservable()
            .map { $0?.sereyPrice ?? 0 }
            ~> self.sereyPrice
            ~ self.disposeBag
    }
    
    func setUpTickerDataChanged() {
        guard let tickerModel = self.sereyTicker.value else {
            return
        }
        
        Observable.from(object: tickerModel)
            .asObservable()
            .subscribe(onNext: { [unowned self] (tickerModel) in
                self.sereyPrice.accept(tickerModel.sereyPrice)
            }) ~ self.disposeBag
    }
}

// MARK: - Networks
extension CoinPriceManager {
    
    func fetchTicker() {
        self.coinService.fetchTicker()
            .subscribe(onNext: { [weak self] data in
                data.save()
                if self?.sereyTicker.value == nil {
                    self?.sereyTicker.accept(data)
                    self?.setUpTickerDataChanged()
                }
            }, onError: { error in
                
            }) ~ self.disposeBag
    }
}
