//
//  CoinService.swift
//  SereyMarket
//
//  Created by Panha Uy on 5/7/21.
//  Copyright © 2021 Serey Marketplace. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift

class CoinService: AppService<CoinApi> {
    
    func fetchTicker() -> Observable<TickerModel> {
        return provider.rx.requestObject(.ticker, type: TickerModel.self)
            .asObservable()
            .map { $0 }
    }
}
