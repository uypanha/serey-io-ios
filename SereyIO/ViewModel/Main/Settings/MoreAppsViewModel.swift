//
//  MoreAppsViewModel.swift
//  SereyIO
//
//  Created by Panha Uy on 4/8/20.
//  Copyright © 2020 Phanha Uy. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift
import RxBinding
import RxDataSources

class MoreAppsViewModel: BaseListTableViewModel {
    
    init() {
        super.init([], true)
        
        self.cells.accept(self.prepareCells())
    }
    
    override func downloadData() {
        super.downloadData()
    }
    
    override func registerTableViewCell(_ tableView: UITableView) {
        super.registerTableViewCell(tableView)
        tableView.register(SereyAppTableViewCell.self)
    }
    
    override func configureCell(_ datasource: TableViewSectionedDataSource<SectionItem>, _ tableView: UITableView, _ indexPath: IndexPath, _ item: CellViewModel) -> UITableViewCell {
        switch item {
        case is SereyAppCellViewModel:
            let cell: SereyAppTableViewCell = tableView.dequeueReusableCell(forIndexPath: indexPath)
            cell.cellModel = item as? SereyAppCellViewModel
            return cell
        default:
            return super.configureCell(datasource, tableView, indexPath, item)
        }
    }
}

// MARK: - Preparations & Tools
extension MoreAppsViewModel {
    
    func prepareCells() -> [SectionItem] {
        let items: [SereyApp] = SereyApp.allCases
        return [SectionItem(items: items.map { SereyAppCellViewModel($0) })]
    }
}
