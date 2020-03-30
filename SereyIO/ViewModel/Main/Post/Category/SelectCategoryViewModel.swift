//
//  SelectCategoryViewModel.swift
//  SereyIO
//
//  Created by Panha Uy on 3/30/20.
//  Copyright © 2020 Phanha Uy. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxBinding
import RxDataSources

class SelectCategoryViewModel: BaseListTableViewModel {
    
    let categories: BehaviorRelay<[DiscussionCategoryModel]>
    let shouldSelectCategory: PublishSubject<DiscussionCategoryModel>
    
    init(_ categories: [DiscussionCategoryModel]) {
        self.categories = BehaviorRelay(value: categories)
        self.shouldSelectCategory = PublishSubject()
        super.init([])
        
        setUpRxObservers()
    }
    
    override func registerTableViewCell(_ tableView: UITableView) {
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

// NARK: - Preparations & Tools
extension SelectCategoryViewModel {
    
    fileprivate func prepareCells(_ categories: [DiscussionCategoryModel]) -> [SectionItem] {
        let items = categories.map { CategoryCellViewModel($0, indicatorAccessory: false) }
        return [SectionItem(items: items)]
    }
}

// MARK: - Action Handlers
fileprivate extension SelectCategoryViewModel {
    
    func handleItemSelected(_ indexPath: IndexPath) {
        if let item = item(at: indexPath) as? CategoryCellViewModel {
            self.shouldSelectCategory.onNext(item.category)
            self.shouldDismiss.onNext(true)
        }
    }
}

// MARK: - SetUp RxObservers
extension SelectCategoryViewModel {
    
    func setUpRxObservers() {
        setUpContentObservers()
    }
    
    func setUpContentObservers() {
        self.categories.asObservable()
            .map { self.prepareCells($0) }
            ~> self.cells
            ~ self.disposeBag
        
        self.didActionSubject.asObservable()
            .subscribe(onNext: { [weak self] action in
                switch action {
                case .itemSelected(let indedPath):
                    self?.handleItemSelected(indedPath)
                }
            }) ~ self.disposeBag
    }
}
