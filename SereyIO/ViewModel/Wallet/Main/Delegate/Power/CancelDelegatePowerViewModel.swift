//
//  CancelDelegatePowerViewModel.swift
//  SereyIO
//
//  Created by Panha Uy on 12/10/22.
//  Copyright © 2022 Serey IO. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift
import RxBinding

class CancelDelegatePowerViewModel: BaseInitTransactionViewModel, CollectionSingleSecitionProviderModel, DownloadStateNetworkProtocol, ShouldPresent {
    
    enum ViewToPresent {
        case loading(Bool)
        case confirmCancelDelegateController(viewModel: ConfirmDialogViewModel)
        case showAlertDialogController(AlertDialogModel)
    }
    
    // output:
    let shouldPresentSubject: PublishSubject<ViewToPresent>
    
    let deletionUsers: BehaviorRelay<[DelegatedUserModel]>
    let cells: BehaviorRelay<[CellViewModel]>
    let shouldShowEmptyView: BehaviorSubject<EmptyOrErrorViewModel?>
    
    let isDownloading: BehaviorRelay<Bool>
    
    override init() {
        self.shouldPresentSubject = .init()
        
        self.deletionUsers = .init(value: [])
        self.cells = .init(value: [])
        self.shouldShowEmptyView = .init(value: nil)
        self.isDownloading = .init(value: false)
        super.init()
        
        setUpRxObservers()
    }
}

// MARK: - Networks
extension CancelDelegatePowerViewModel {
    
    func downloadData() {
        if !self.isDownloading.value {
            self.isDownloading.accept(true)
            fetchDelegationList()
        }
    }
    
    private func fetchDelegationList() {
        self.transferService.fetchDelegationList()
            .subscribe(onNext: { [weak self] data in
                self?.isDownloading.accept(false)
                self?.deletionUsers.accept(data)
            }, onError: { [weak self] error in
                self?.isDownloading.accept(false)
                self?.shouldPresentError(ErrorHelper.prepareError(error: error))
            }) ~ self.disposeBag
    }
    
    private func cancelDelegatePower(from account: String) {
        self.shouldPresent(.loading(true))
        self.transferService.delegatePower(account, amount: 0.0)
            .subscribe(onNext: { [weak self] data in
                self?.shouldPresent(.loading(false))
                self?.handleDelegateSuccess(account)
            }, onError: { [weak self] error in
                self?.shouldPresent(.loading(false))
                let errorInfo = ErrorHelper.prepareError(error: error)
                self?.shouldPresentError(errorInfo)
            }) ~ self.disposeBag
    }
}

// MARK: - Preparations & Tools
extension CancelDelegatePowerViewModel {
    
    func prepareCells() -> [CellViewModel] {
        var items: [CellViewModel] = []
        
        items.append(contentsOf: self.deletionUsers.value.map {
            DelegatedUserCellViewModel($0).then {
                self.setUpDelegateUserCellObservers($0)
            }
        })
        
        if items.isEmpty && self.isDownloading.value {
            items.append(contentsOf: (0...Int.random(in: (4..<7))).map { _ in DelegatedUserCellViewModel(true) })
        }
        return items
    }
    
    private func shouldShowEmptyResults() -> EmptyOrErrorViewModel? {
        if self.cells.value.isEmpty {
            return .init(withErrorEmptyModel: .init(withEmptyTitle: "No Data".localize(), emptyDescription: "Once you delegate power to any user, it will be shown here.".localize(), imageWidthOffset: 0.9, iconImage: R.image.emptyDelegation()))
        }
        return nil
    }
    
    private func remove(username: String) {
        let users = self.deletionUsers.value.filter { $0.userName != username }
        self.deletionUsers.accept(users)
    }
}

// MARK: - Action Handlers
fileprivate extension CancelDelegatePowerViewModel {
    
    func handleRemoveDelegationPressed(from delegateUser: DelegatedUserModel) {
        
        func showConfirmDialog() {
            let title = "Cancel Delegation".localize()
            let message = "Are you sure you want to cancel delegation power from \"\(delegateUser.userName)\"?".localize()
            let viewModel = ConfirmDialogViewModel(title: title, message: message, action: .init("Confirm".localize(), style: .default, completion: {
                self.cancelDelegatePower(from: delegateUser.userName)
            }))
            self.shouldPresent(.confirmCancelDelegateController(viewModel: viewModel))
        }
        
        self.shouldPresent(.loading(true))
        self.initTransaction {
            self.shouldPresent(.loading(false))
            showConfirmDialog()
        }
    }
    
    func handleDelegateSuccess(_ account: String) {
        let confirmAction = ActionModel(R.string.common.confirm.localized(), style: .default) {
            self.didTransactionUpdate.onNext(())
            self.remove(username: account)
        }
        
        let alerDialogModel = AlertDialogModel(title: "Delegate".localize(), message: "You’ve just cancelled delegation Serey Power to \(account).".localize(), actions: [confirmAction])
        self.shouldPresent(.showAlertDialogController(alerDialogModel))
    }
}

// MARK: - SetUp RxObservers
fileprivate extension CancelDelegatePowerViewModel {
    
    func setUpRxObservers() {
        setUpContentChangedObservers()
    }
    
    func setUpContentChangedObservers() {
        self.deletionUsers.asObservable()
            .map { _ in self.prepareCells() }
            ~> self.cells
            ~ self.disposeBag
        
        self.cells.asObservable()
            .map { _ in self.shouldShowEmptyResults() }
            ~> self.shouldShowEmptyView
            ~ self.disposeBag
        
        self.isDownloading.asObservable()
            .map { _ in self.prepareCells() }
            ~> self.cells
            ~ self.disposeBag
    }
    
    func setUpDelegateUserCellObservers(_ cellModel: DelegatedUserCellViewModel) {
        cellModel.shouldRemoveDelegate.asObservable()
            .subscribe(onNext: { [weak self] data in
                self?.handleRemoveDelegationPressed(from: data)
            }) ~ cellModel.disposeBag
    }
}
