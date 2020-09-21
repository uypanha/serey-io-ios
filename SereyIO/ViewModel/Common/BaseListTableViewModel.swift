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

class BaseListTableViewModel: BaseCellViewModel, CollectionMultiSectionsProviderModel, DownloadStateNetworkProtocol {
    
    let cells: BehaviorRelay<[SectionItem]>
    let isDownloading: BehaviorRelay<Bool>
    let emptyOrError: BehaviorSubject<EmptyOrErrorViewModel?>
    
    let shouldDismiss: PublishSubject<Bool>
    let itemSelected: PublishSubject<IndexPath>
    let showBorder: Bool
    
    init(_ items: [SectionItem], _ showBorder: Bool = false) {
        self.cells = BehaviorRelay(value: items)
        self.isDownloading = BehaviorRelay(value: false)
        self.shouldDismiss = PublishSubject()
        self.showBorder = showBorder
        self.emptyOrError = BehaviorSubject(value: nil)
        self.itemSelected = PublishSubject()
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
