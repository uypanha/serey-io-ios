//
//  NotificationCellViewModel.swift
//  SereyIO
//
//  Created by Panha Uy on 9/28/21.
//  Copyright © 2021 Serey IO. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift
import RxBinding

class NotificationCellViewModel: CellViewModel, ShimmeringProtocol {
    
    let notification: BehaviorRelay<NotificationModel?>
    
    let profileViewModel: BehaviorSubject<ProfileViewModel?>
    let captionAttributedString: BehaviorSubject<NSAttributedString?>
    let createdAt: BehaviorSubject<String?>
    let backgroundColor: BehaviorSubject<UIColor?>
    let isThumbnailHidden: BehaviorSubject<Bool>
    let thumbnailUrl: BehaviorSubject<URL?>
    
    let isShimmering: BehaviorRelay<Bool>
    
    init(_ notification: NotificationModel?) {
        self.notification = .init(value: notification)
        
        self.profileViewModel = .init(value: nil)
        self.captionAttributedString = .init(value: nil)
        self.createdAt = .init(value: nil)
        self.backgroundColor = .init(value: .white)
        self.isThumbnailHidden = .init(value: false)
        self.thumbnailUrl = .init(value: nil)
        
        self.isShimmering = .init(value: false)
        super.init(false, .none)
        
        setUpRxObservers()
    }
    
    required convenience init(_ isShimmering: Bool) {
        self.init(nil)
        
        self.isShimmering.accept(isShimmering)
    }
}

// MARK: - Preparations & Tools
extension NotificationCellViewModel {
    
    func notifyDataChanged(_ data: NotificationModel?) {
        self.profileViewModel.onNext(data?.profileViewModel)
        self.captionAttributedString.onNext(data?.captionAttributedString)
        self.createdAt.onNext(data?.createdTime)
        self.backgroundColor.onNext(data?.isRead == false ? UIColor.color(.primary).withAlphaComponent(0.1) : .clear)
        self.thumbnailUrl.onNext(data?.postThumbnailUrl)
        self.isThumbnailHidden.onNext(data?.isPost == false)
    }
}

// MARK: - SetUp RxObservers
extension NotificationCellViewModel {
    
    func setUpRxObservers() {
        self.notification.asObservable()
            .subscribe(onNext: { [weak self] notification in
                self?.notifyDataChanged(notification)
            }) ~ self.disposeBag
    }
}
