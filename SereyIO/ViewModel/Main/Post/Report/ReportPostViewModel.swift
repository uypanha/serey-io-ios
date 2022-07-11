//
//  ReportPostViewModel.swift
//  SereyIO
//
//  Created by Mäd on 26/01/2022.
//  Copyright © 2022 Serey IO. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift
import RxBinding

class ReportPostViewModel: BaseViewModel, CollectionSingleSecitionProviderModel, DownloadStateNetworkProtocol, ShouldReactToAction, ShouldPresent {
    
    enum Action {
        case itemSelected(IndexPath)
    }
    
    enum ViewToPresent {
        case loading(Bool)
        case confirmDialogController(viewModel: ConfirmDialogViewModel, dismissable: Bool = true)
        case enterIssueViewController(EnterIssueViewModel)
        case dismiss
    }
    
    // input:
    let didActionSubject: PublishSubject<Action>
    
    // output:
    let shouldPresentSubject: PublishSubject<ViewToPresent>
    
    let post: PostModel
    let cells: BehaviorRelay<[CellViewModel]>
    let types: BehaviorRelay<[ReportTypeModel]>
    
    let isDownloading: BehaviorRelay<Bool>
    let discussionService: DiscussionService
    
    init(with post: PostModel) {
        self.post = post
        self.didActionSubject = .init()
        self.shouldPresentSubject = .init()
        
        self.isDownloading = .init(value: false)
        self.cells = .init(value: [])
        self.types = .init(value: [])
        
        self.discussionService = .init()
        super.init()
        
        setUpRxObservers()
    }
}

// MARK: - Networks
extension ReportPostViewModel {
    
    func downloadData() {
        if !self.isDownloading.value {
            self.isDownloading.accept(true)
            self.fetchReportTypes()
        }
    }
    
    func fetchReportTypes() {
        self.discussionService.getReportTypes()
            .subscribe(onNext: { [weak self] data in
                self?.types.accept(data.reportTypes)
            }, onError: { [weak self] error in
                self?.shouldPresentError(ErrorHelper.prepareError(error: error))
            }) ~ self.disposeBag
    }
    
    func reportPost(with type: ReportTypeModel) {
        self.shouldPresent(.loading(true))
        self.discussionService.reportPost(self.post.id ?? "", typeId: type.id, description: type.title)
            .subscribe(onNext: { [weak self] data in
                self?.shouldPresent(.loading(false))
                self?.handleReportSuccess()
            }, onError: { [weak self] error in
                self?.shouldPresent(.loading(false))
                self?.shouldPresentError(ErrorHelper.prepareError(error: error))
            }) ~ self.disposeBag
    }
}

// MARK: - Preparations & Tools
extension ReportPostViewModel {
    
    func prepareCells() -> [CellViewModel] {
        var items: [CellViewModel] = self.types.value.map { ReportTypeCellViewModel($0) }
        if items.isEmpty && self.isDownloading.value {
            items.append(contentsOf: (0...6).map { _ in ReportTypeCellViewModel(true) })
        }
        return items
    }
}

// MARK: - Action Handlers
extension ReportPostViewModel {
    
    func handleItemSelected(_ indexPath: IndexPath) {
        if let item = self.item(at: indexPath) as? ReportTypeCellViewModel, let type = item.type {
            if type.title != "Something Else" {
                let message = "Are you sure to report this post as \"\(type.title)\"?"
                let action = ActionModel("Submit", style: .default) {
                    self.reportPost(with: type)
                }
                let viewModel = ConfirmDialogViewModel(title: "Report this post?", message: message, action: action)
                self.shouldPresent(.confirmDialogController(viewModel: viewModel))
            } else {
                self.shouldPresent(.enterIssueViewController(.init(from: self.post.id ?? "", with: type)))
            }
        }
    }
    
    func handleReportSuccess() {
        let message = "We’ll use this information to improve our process. Independent fact-checkers may review the article."
        let action = ActionModel("Done", style: .default) {
            self.shouldPresent(.dismiss)
        }
        let viewModel = ConfirmDialogViewModel(title: "Thanks for letting us know.", message: message, action: action)
        self.shouldPresent(.confirmDialogController(viewModel: viewModel, dismissable: false))
    }
}

// MARK: - SetUp RxObservers
extension ReportPostViewModel {
    
    func setUpRxObservers() {
        setUpContentChangedObservers()
        setUpActionObservers()
    }
    
    func setUpContentChangedObservers() {
        self.types.asObservable()
            .map { _ in self.prepareCells() }
            ~> self.cells
            ~ self.disposeBag
        
        self.isDownloading.asObservable()
            .map { _ in self.prepareCells() }
            ~> self.cells
            ~ self.disposeBag
    }
    
    func setUpActionObservers() {
        self.didActionSubject.asObservable()
            .subscribe(onNext: { [weak self] action in
                switch action {
                case .itemSelected(let indexPath):
                    self?.handleItemSelected(indexPath)
                }
            }) ~ self.disposeBag
    }
}

// MARK: - Report Cell
class ReportTypeCellViewModel: TextCellViewModel {
    
    let type: ReportTypeModel?
    
    init(_ type: ReportTypeModel?) {
        self.type = type
        super.init(with: type?.title ?? "", properties: .defaultProperties(), indicatorAccessory: true)
    }
    
    convenience required init(_ isShimmering: Bool) {
        self.init(nil)
        
        self.indicatorAccessory.onNext(false)
        self.isShimmering.accept(isShimmering)
    }
}
