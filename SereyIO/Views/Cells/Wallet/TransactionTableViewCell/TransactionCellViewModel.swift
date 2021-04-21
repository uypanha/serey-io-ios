//
//  TransactionCellViewModel.swift
//  SereyIO
//
//  Created by Panha Uy on 8/6/20.
//  Copyright © 2020 Serey IO. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift
import RxBinding

class TransactionCellViewModel: CellViewModel, ShimmeringProtocol {
    
    let transaction: BehaviorRelay<TransactionModel?>
    
    let isShimmering: BehaviorRelay<Bool>
    let typeImage: BehaviorSubject<UIImage?>
    let typeText: BehaviorSubject<String?>
    let timeStamp: BehaviorSubject<String?>
    let valueText: BehaviorSubject<String?>
    let valueColor: BehaviorSubject<UIColor?>
    
    required convenience init(_ isShimmering: Bool) {
        self.init(nil)
        
        self.isShimmering.accept(isShimmering)
    }
    
    init(_ transaction: TransactionModel?) {
        self.transaction = .init(value: transaction)
        self.isShimmering = .init(value: false)
        
        self.typeImage = .init(value: nil)
        self.typeText = .init(value: nil)
        self.timeStamp = .init(value: nil)
        self.valueText = .init(value: nil)
        self.valueColor = .init(value: nil)
        super.init()
        
        setUpRxObservers()
    }
}

// MARK: - Preparations & Tools
extension TransactionCellViewModel {
    
    func notifyDataChanged(_ data: TransactionModel?) {
        self.typeImage.onNext(data?.typeImage)
        self.timeStamp.onNext(data?.createDateString)
        self.typeText.onNext(data?.typeTitle)
        self.valueText.onNext(data?.value)
        self.valueColor.onNext(data?.valueColor)
    }
}

// MARK: - SetUp RxObservers
extension TransactionCellViewModel {
    
    func setUpRxObservers() {
        self.transaction.asObservable()
            .subscribe(onNext: { [weak self] transaction in
                self?.notifyDataChanged(transaction)
            }) ~ self.disposeBag
    }
}
