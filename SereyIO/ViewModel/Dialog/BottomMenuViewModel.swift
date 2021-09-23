//
//  BottomMenuViewModel.swift
//  SereyIO
//
//  Created by Panha Uy on 3/26/20.
//  Copyright © 2020 Serey IO. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift
import RxBinding
import RxDataSources

class BottomListMenuViewModel: BaseListTableViewModel {
    
    let shouldSelectMenuItem: PublishSubject<ImageTextCellViewModel>
    
    init(header: String? = nil,_ items: [ImageTextCellViewModel]) {
        self.shouldSelectMenuItem = PublishSubject()
        super.init([SectionItem(model: .init(header: header), items: items)])
        
        setUpRxObservers()
    }
    
    override func registerTableViewCell(_ tableView: UITableView) {
        tableView.register(ImageTextTableViewCell.self)
    }
    
    override func configureCell(_ datasource: TableViewSectionedDataSource<SectionItem>, _ tableView: UITableView, _ indexPath: IndexPath, _ item: CellViewModel) -> UITableViewCell {
        switch item {
        case is ImageTextCellViewModel:
            let cell: ImageTextTableViewCell = tableView.dequeueReusableCell(forIndexPath: indexPath)
            cell.cellModel = item as? ImageTextCellViewModel
            return cell
        default:
            return UITableViewCell()
        }
    }
}

// MARK: - SetUp RxObservers
fileprivate extension BottomListMenuViewModel {
    
    func setUpRxObservers() {
        setUpActionObservers()
    }
    
    func setUpActionObservers() {
        self.itemSelected.asObservable()
            .subscribe(onNext: { [weak self] indexPath in
                self?.shouldDismiss.onNext(true)
                if let item = self?.item(at: indexPath) as? ImageTextCellViewModel {
                    self?.shouldSelectMenuItem.onNext(item)
                }
            }) ~ self.disposeBag
    }
}
