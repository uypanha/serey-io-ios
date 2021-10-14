//
//  NotificationViewModel.swift
//  SereyIO
//
//  Created by Panha Uy on 9/23/21.
//  Copyright © 2021 Serey IO. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift
import RxBinding

class NotificationViewModel: BaseViewModel, CollectionMultiSectionsProviderModel, InfiniteNetworkProtocol, ShouldReactToAction, ShouldPresent {
    
    enum Action {
        case itemSelected(IndexPath)
        case refresh
    }
    
    enum ViewToPresent {
        case postDetailViewController(PostDetailViewModel)
        case profileViewController(UserAccountViewModel)
        case signInController(SignInViewModel)
    }
    
    // input:
    let didActionSubject: PublishSubject<Action>
    
    // output:
    let shouldPresentSubject: PublishSubject<ViewToPresent>
    
    let cells: BehaviorRelay<[SectionItem]>
    let notifications: BehaviorRelay<[NotificationModel]>
    let emptyOrErrorViewModel: BehaviorSubject<EmptyOrErrorViewModel?>
    
    let canDownloadMorePages: BehaviorRelay<Bool>
    let isRefresh: BehaviorRelay<Bool>
    let isDownloading: BehaviorRelay<Bool>
    var pageModel: PaginationRequestModel
    var downloadDisposeBag: DisposeBag
    
    let notificationService: NotificationService
    
    override init() {
        self.didActionSubject = .init()
        self.shouldPresentSubject = .init()
        
        self.cells = .init(value: [])
        self.notifications = .init(value: [])
        self.emptyOrErrorViewModel = .init(value: nil)
        
        self.canDownloadMorePages = .init(value: true)
        self.isRefresh = .init(value: true)
        self.isDownloading = .init(value: false)
        self.pageModel = .init()
        self.downloadDisposeBag = .init()
        
        self.notificationService = .init()
        super.init()
        
        setUpRxObservers()
    }
}

// MARK: - Networks
extension NotificationViewModel {
    
    func downloadData() {
        if AuthData.shared.isUserLoggedIn {
            if self.canDownloadMore() && !self.isDownloading.value {
                self.isDownloading.accept(true)
                self.fetchNotifications()
            }
        }
    }
    
    private func fetchNotifications() {
        self.notificationService.fetchNotifications(self.pageModel)
            .subscribe(onNext: { [weak self] data in
                self?.isDownloading.accept(false)
                self?.updateData(data)
            }, onError: { [weak self] error in
                self?.isDownloading.accept(false)
                self?.shouldPresentError(ErrorHelper.prepareError(error: error))
            }) ~ self.disposeBag
    }
    
    private func updateRead(id: String) {
        self.notificationService.updateRead(id)
            .subscribe(onNext: { [weak self] data in
                self?.updateData(data)
            }) ~ self.disposeBag
    }
}

// MARK: - Preparations & Tools
extension NotificationViewModel {
    
    func updateData(_ data: NotificationsResponseModel) {
        var notifications = self.notifications.value
        if self.isRefresh.value {
            self.isRefresh.accept(false)
            notifications.removeAll()
        }
        
        notifications.append(contentsOf: data.notifications)
        
        if data.notifications.isEmpty || pageModel.limit > data.notifications.count {
            canDownloadMorePages.accept(false)
        }
        if data.notifications.count > 0 {
            self.pageModel.offset = notifications.count
        }
        
        self.notifications.accept(notifications)
    }
    
    func updateData(_ data: NotificationModel) {
        var notifications = self.notifications.value
        
        if let indexToUpdate = notifications.firstIndex(where: { $0.id == data.id }) {
            notifications[indexToUpdate] = data
        } else {
            notifications.insert(data, at: 0)
        }
        
        self.notifications.accept(notifications)
    }
    
    func prepareCells() -> [SectionItem] {
        var sections : [SectionItem] = []
        
        if AuthData.shared.isUserLoggedIn {
            if !self.notifications.value.isEmpty {
                sections.append(.init(items: self.notifications.value.map { NotificationCellViewModel($0) }))
            }
            
            if self.canDownloadMore() {
                if sections.isEmpty {
                    sections.append(.init(items: (0...10).map { _ in NotificationCellViewModel(true) }))
                } else {
                    sections.append(.init(items: [NotificationCellViewModel(true)]))
                }
            }
        }
        
        return sections
    }
    
    func prepareEmptyModel() -> EmptyOrErrorViewModel? {
        if !AuthData.shared.isUserLoggedIn {
            return .init(withErrorEmptyModel: .init(withEmptyTitle: "You're not logged in", emptyDescription: "To access this feature you need to login first or sign up to create account.", iconImage: R.image.loginIcon(), actionTitle: "Login") {
                self.shouldPresent(.signInController(.init()))
            })
        } else if !self.isDownloading.value && self.notifications.value.isEmpty {
            return .init(withErrorEmptyModel: .init(withEmptyTitle: "No notification, yet.", emptyDescription: "We will let you know when we've got new for you.", iconImage: R.image.notificationIcon()))
        }
        return nil
    }
    
    func shouldUpdateCells() {
        var _self = self
        _self.reset()
        self.notifications.accept([])
    }
    
    func shouldPrepareCells() {
        self.cells.accept(self.prepareCells())
    }
}

// MARK: - Action Handlers
fileprivate extension NotificationViewModel {
    
    func handleItemSelected(_ indexPath: IndexPath) {
        if let item = self.item(at: indexPath) as? NotificationCellViewModel, let notificaiton = item.notification.value {
            if notificaiton.type == "COMMENT" || notificaiton.type == "VOTE" {
                let author = notificaiton.information.postAuthor ?? ""
                let permlink = notificaiton.information.postPermlink ?? ""
                self.shouldPresent(.postDetailViewController(.init(permlink, author)))
            } else if notificaiton.type == "FOLLOW" {
                self.shouldPresent(.profileViewController(.init(notificaiton.actor)))
            }
            if !notificaiton.isRead {
                self.updateRead(id: notificaiton.id)
            }
        }
    }
}

// MARK: - SetUp RxObservers
extension NotificationViewModel {
    
    func setUpRxObservers() {
        setUpContentChangedObservers()
        setUpActionObservers()
    }
    
    func setUpContentChangedObservers() {
        self.notifications.asObservable()
            .map { _ in self.prepareCells() }
            ~> self.cells
            ~ self.disposeBag
        
        self.cells.asObservable()
            .map { _ in self.prepareEmptyModel() }
            ~> self.emptyOrErrorViewModel
            ~ self.disposeBag
    }
    
    func setUpActionObservers() {
        self.didActionSubject.asObservable()
            .subscribe(onNext: { [weak self] action in
                switch action {
                case .itemSelected(let indexPath):
                    self?.handleItemSelected(indexPath)
                case .refresh:
                    self?.reset()
                }
            }) ~ self.disposeBag
    }
}
