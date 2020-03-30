//
//  BaseListTableViewModel.swift
//  SereyIO
//
//  Created by Panha Uy on 3/30/20.
//  Copyright © 2020 Phanha Uy. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift
import RxDataSources

class BaseListTableViewModel: BaseCellViewModel, ShouldReactToAction,
    CollectionMultiSectionsProviderModel, DownloadStateNetworkProtocol {
    
    enum Action {
        case itemSelected(IndexPath)
    }
    
    // input:
    lazy var didActionSubject = PublishSubject<Action>()
    
    let cells: BehaviorRelay<[SectionItem]>
    let isDownloading: BehaviorRelay<Bool>
    
    let shouldDismiss: PublishSubject<Bool>
    
    init(_ items: [SectionItem]) {
        self.cells = BehaviorRelay(value: items)
        self.isDownloading = BehaviorRelay(value: false)
        self.shouldDismiss = PublishSubject()
        super.init()
    }
    
    open func downloadData() {
    }
    
    open func registerTableViewCell(_ tableView: UITableView) {
    }
    
    func prepareDatasource() -> RxTableViewSectionedReloadDataSource<SectionItem> {
        return RxTableViewSectionedReloadDataSource<SectionItem>(configureCell: configureCell)
    }
    
    open func configureCell(_ datasource: TableViewSectionedDataSource<SectionItem>, _ tableView: UITableView, _ indexPath: IndexPath, _ item: CellViewModel) -> UITableViewCell {
        return UITableViewCell()
    }
}
