//
//  MyReferralIdViewModel.swift
//  SereyIO
//
//  Created by Panha on 30/3/22.
//  Copyright © 2022 Serey IO. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift
import RxBinding
import UIKit

class MyReferralIdViewModel: BaseViewModel, DownloadStateNetworkProtocol, ShouldReactToAction, ShouldPresent {
    
    enum Action {
        case copyLinkPressed
        case invitePressed
    }
    
    enum ViewToPresent {
        case showSnackBar(String)
        case inviteFriendDialogController(InviteFriendDialogViewModel)
        case shareLink(URL)
    }
    
    // input:
    let didActionSubject: PublishSubject<Action>
    
    // output:
    let shouldPresentSubject: PublishSubject<ViewToPresent>
    
    let referralId: BehaviorRelay<String?>
    let referralUrl: BehaviorRelay<String?>
    
    let isDownloading: BehaviorRelay<Bool>
    let userService: UserService
    
    override init() {
        self.didActionSubject = .init()
        self.shouldPresentSubject = .init()
        
        self.referralId = .init(value: nil)
        self.referralUrl = .init(value: nil)
        
        self.isDownloading = .init(value: false)
        self.userService = .init()
        super.init()
        
        setUpRxObservers()
    }
}

// MARK: - Networks
extension MyReferralIdViewModel {
    
    func downloadData() {
        if !self.isDownloading.value {
            self.isDownloading.accept(true)
            self.fetchMyReferralId()
        }
    }
    
    private func fetchMyReferralId() {
        self.userService.fetchReferralId()
            .subscribe(onNext: { [weak self] data in
                if let data = data.value as? [String: Any], let id = data["referral_id"] as? String? {
                    self?.referralId.accept(id)
                    self?.isDownloading.accept(false)
                } else {
                    self?.addReferralId()
                }
            }, onError: { [weak self] error in
                self?.isDownloading.accept(false)
                if let apiError = error as? AppError {
                    switch apiError {
                    case .appApiError(let error, _):
                        if error.errorCode == AppApiErrorCode.internalServerError.rawValue {
                            self?.shouldPresentError(ErrorHelper.PredefinedError.referralIdError.prepareError())
                            return
                        }
                    }
                }
                self?.shouldPresentError(ErrorHelper.prepareError(error: error))
            }) ~ self.disposeBag
    }
    
    private func addReferralId() {
        self.userService.addReferralId()
            .subscribe(onNext: { [weak self] data in
                self?.isDownloading.accept(false)
                if let data = data.value as? [String: Any], let id = data["referral_id"] as? String? {
                    self?.referralId.accept(id)
                }
            }, onError: { [weak self] error in
                self?.isDownloading.accept(false)
                self?.shouldPresentError(ErrorHelper.prepareError(error: error))
            }) ~ self.disposeBag
    }
}

// MARK: - SetUp RxObservers
private extension MyReferralIdViewModel {
    
    func setUpRxObservers() {
        setUpContentChangedObservers()
        setUpActionObservers()
    }
    
    func setUpContentChangedObservers() {
        self.referralId.asObservable()
            .map { $0 == nil ? nil : "\(Constants.kycURL.description)/?referralId=\($0 ?? "")" }
            ~> self.referralUrl
            ~ self.disposeBag
    }
    
    func setUpActionObservers() {
        self.didActionSubject.asObserver()
            .subscribe(onNext: { [weak self] action in
                switch action {
                case .invitePressed:
                    if let url = URL(string: "\(Constants.kycURL.description)/?referralId=\(self?.referralId.value ?? "")") {
                        self?.shouldPresent(.shareLink(url))
                    }
                case .copyLinkPressed:
                    UIPasteboard.general.string = self?.referralUrl.value
                    self?.shouldPresent(.showSnackBar("Referral Link Copied"))
                }
            }) ~ self.disposeBag
    }
}
