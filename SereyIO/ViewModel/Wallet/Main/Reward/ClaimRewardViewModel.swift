//
//  ClaimRewardViewModel.swift
//  SereyIO
//
//  Created by Panha Uy on 9/5/20.
//  Copyright © 2020 Phanha Uy. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift
import RxBinding

class ClaimRewardViewModel: BaseInitTransactionViewModel, ShouldReactToAction, ShouldPresent {
    
    enum Action {
        case claimRewardPressed
    }
    
    enum ViewToPresent {
        case loading(Bool)
        case dismiss
        case showAlertDialogController(AlertDialogModel)
    }
    
    // input:
    let didActionSubject: PublishSubject<Action>
    
    // output:
    let shouldPresentSubject: PublishSubject<ViewToPresent>
    
    override init() {
        self.didActionSubject = .init()
        self.shouldPresentSubject = .init()
        
        super.init()
        
        setUpRxObservers()
    }
}

// MARK: - Networks
extension ClaimRewardViewModel {
    
    func claimReward() {
        self.isLoading.onNext(true)
        self.transferService.claimReward()
            .subscribe(onNext: { [weak self] data in
                self?.isLoading.onNext(false)
                self?.handleClaimRewardSuccess()
            }, onError: { [weak self] error in
                self?.isLoading.onNext(false)
                let errorInfo = ErrorHelper.prepareError(error: error)
                self?.shouldPresentError(errorInfo)
            }) ~ self.disposeBag
    }
}

// MARK: - Action Handlers
fileprivate extension ClaimRewardViewModel {
    
    func handleClaimRewardPressed() {
        self.isLoading.onNext(true)
        self.initTransaction {
            self.claimReward()
        }
    }
    
    func handleClaimRewardSuccess() {
        let confirmAction = ActionModel(R.string.common.confirm.localized(), style: .default) {
            self.shouldPresent(.dismiss)
            self.didTransactionUpdate.onNext(())
        }
        
        let alerDialogModel = AlertDialogModel(title: "Claim Reward", message: "You just cliam your reward.", actions: [confirmAction])
        self.shouldPresent(.showAlertDialogController(alerDialogModel))
    }
}

// MARK: - SetUP RxObservers
extension ClaimRewardViewModel {
    
    func setUpRxObservers() {
        setUpActionObservers()
        
        self.isLoading.map { ViewToPresent.loading($0) }
            ~> self.shouldPresentSubject
            ~ self.disposeBag
    }
    
    func setUpActionObservers() {
        self.didActionSubject.asObservable()
            .subscribe(onNext: { [weak self] action in
                switch action {
                case .claimRewardPressed:
                    self?.handleClaimRewardPressed()
                }
            }) ~ self.disposeBag
    }
}
