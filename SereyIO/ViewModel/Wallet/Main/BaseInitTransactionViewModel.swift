//
//  BaseInitTransactionViewModel.swift
//  SereyIO
//
//  Created by Panha Uy on 8/28/20.
//  Copyright © 2020 Phanha Uy. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift
import RxBinding

class BaseInitTransactionViewModel: BaseViewModel {
    
    let transferService: TransferService
    
    let isLoading: BehaviorSubject<Bool>
    
    override init() {
        self.transferService = .init()
        self.isLoading = .init(value: false)
        super.init()
    }
}

// MARK: - Networks
extension BaseInitTransactionViewModel {
    
    internal func initTransaction(completion: @escaping () -> Void) {
        self.transferService.initTransaction()
            .subscribe(onNext: { [weak self] data in
                self?.transferService.publicKey = data.publicKey
                self?.transferService.trxId = data.trxId
                self?.isLoading.onNext(false)
                completion()
            }, onError: { [weak self] error in
                self?.isLoading.onNext(false)
                let errorInfo = ErrorHelper.prepareError(error: error)
                self?.shouldPresentError(errorInfo)
            }) ~ self.disposeBag
    }
}
