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

class ReportPostViewModel: BaseViewModel, CollectionSingleSecitionProviderModel, DownloadStateNetworkProtocol {
    
    let cells: BehaviorRelay<[CellViewModel]>
    let types: BehaviorRelay<[ReportTypeModel]>
    
    let isDownloading: BehaviorRelay<Bool>
    let discussionService: DiscussionService
    
    override init() {
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
}

// MARK: - Preparations & Tools
extension ReportPostViewModel {
    
    func prepareCells() -> [CellViewModel] {
        var items: [CellViewModel] = self.types.value.map { TextCellViewModel(with: $0.title, properties: .defaultProperties(), indicatorAccessory: true) }
        if items.isEmpty && self.isDownloading.value {
            items.append(contentsOf: (0...6).map { _ in TextCellViewModel(true) })
        }
        return items
    }
}

// MARK: - SetUp RxObservers
extension ReportPostViewModel {
    
    func setUpRxObservers() {
        setUpContentChangedObservers()
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
}
