//
//  TransactionDetailViewModel.swift
//  SereyIO
//
//  Created by Panha Uy on 9/9/20.
//  Copyright © 2020 Phanha Uy. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift
import RxBinding
import RxDataSources

class TransactionDetailViewModel: BaseListTableViewModel {
    
    let transaction: TransactionModel
    
    init(_ transaction: TransactionModel) {
        self.transaction = transaction
        super.init([])
        
        self.cells.accept(self.prepareCells(transaction))
    }
    
    override func registerTableViewCell(_ tableView: UITableView) {
        super.registerTableViewCell(tableView)
        
        tableView.separatorStyle = .none
        tableView.register(TransactionInfoTableViewCell.self)
        tableView.register(TextTableViewCell.self)
    }
    
    override func configureCell(_ datasource: TableViewSectionedDataSource<SectionItem>, _ tableView: UITableView, _ indexPath: IndexPath, _ item: CellViewModel) -> UITableViewCell {
        switch item {
        case is TextCellViewModel:
            let cell: TextTableViewCell = tableView.dequeueReusableCell(forIndexPath: indexPath)
            cell.cellModel = item as? TextCellViewModel
            return cell
        default:
            return UITableViewCell()
        }
    }
}

// MARK: - Preparations & Tools
extension TransactionDetailViewModel {
    
    func prepareCells(_ transaction: TransactionModel) -> [SectionItem] {
        return [SectionItem(items: transaction.infoCells)]
    }
}
