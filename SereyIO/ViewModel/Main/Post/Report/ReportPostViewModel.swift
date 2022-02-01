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
        case confirmDialogController(String, String, String, () -> Void)
        case enterIssueViewController
    }
    
    // input:
    let didActionSubject: PublishSubject<Action>
    
    // output:
    let shouldPresentSubject: PublishSubject<ViewToPresent>
    
    let cells: BehaviorRelay<[CellViewModel]>
    let types: BehaviorRelay<[ReportTypeModel]>
    
    let isDownloading: BehaviorRelay<Bool>
    let discussionService: DiscussionService
    
    override init() {
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
                self.shouldPresent(.confirmDialogController("Report this post?", message, "Submit", {
                    self.reportPost(with: type)
                }))
            } else {
                self.shouldPresent(.enterIssueViewController)
            }
        }
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
