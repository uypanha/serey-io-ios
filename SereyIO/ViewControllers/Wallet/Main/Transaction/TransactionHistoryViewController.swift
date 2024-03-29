//
//  TransactionHistoryViewController.swift
//  SereyIO
//
//  Created by Panha Uy on 7/2/20.
//  Copyright © 2020 Serey IO. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift
import RxBinding
import RxDataSources

class TransactionHistoryViewController: BaseTableViewController {
    
    fileprivate weak var emptyView: EmptyOrErrorView? = nil {
        didSet {
            self.tableView?.backgroundView = emptyView
        }
    }
    
    lazy var dataSource: RxTableViewSectionedReloadDataSource<SectionItem> = { [unowned self] in
        return self.prepreDataSource()
    }()
    
    var viewModel: TransactionHistoryViewModel!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setUpViews()
        setUpRxObservers()
        viewModel.downloadData()
    }
    
    override func setUpLocalizedTexts() {
        super.setUpLocalizedTexts()
        
        self.title = "Transaction History"
    }
}

// MARK: - Preparations & Tools
extension TransactionHistoryViewController {
    
    func setUpViews() {
        prepareTableView()
    }
    
    func prepareTableView() {
        self.tableView.separatorColor = .color(.border)
        self.tableView.tableFooterView = UIView()
        
        self.tableView.register(TransactionTableViewCell.self)
    }
    
    func prepreDataSource() -> RxTableViewSectionedReloadDataSource<SectionItem> {
        let dataSource = RxTableViewSectionedReloadDataSource<SectionItem>(configureCell: { (datasource, tableView, indexPath, item) -> UITableViewCell in
            switch item {
            case is TransactionCellViewModel:
                let cell: TransactionTableViewCell = tableView.dequeueReusableCell(forIndexPath: indexPath)
                cell.cellModel = item as? TransactionCellViewModel
                return cell
            default:
                return UITableViewCell()
            }
        })
        
        dataSource.titleForHeaderInSection = { dataSource, index in
            return dataSource.sectionModels[index].model.header
        }
        
        return dataSource
    }
    
}

// MARK: - Preparations & Tools
extension TransactionHistoryViewController {
    
    func prepareToDisplayEmptyView(_ model: EmptyOrErrorViewModel) {
        let emptyView = EmptyOrErrorView()
        emptyView.viewModel = model
        self.emptyView = emptyView
    }
}

// MARK: - SetUp RxObservers
extension TransactionHistoryViewController {
    
    func setUpRxObservers() {
        setUpContentChangedObservers()
        setUpShouldPresentObservers()
    }
    
    func setUpContentChangedObservers() {
        self.viewModel.cells.asObservable()
            .`do`(onNext: { [weak self] cells in
                if !cells.isEmpty {
                    self?.emptyView?.removeFromSuperview()
                    self?.emptyView = nil
                }
            })
            .bind(to: self.tableView.rx.items(dataSource: self.dataSource))
            .disposed(by: self.disposeBag)
        
        // Item Selected
        self.tableView.rx.itemSelected.asObservable()
            .`do`(onNext: { [weak self] indexPath  in
                self?.tableView.deselectRow(at: indexPath, animated: true)
            })
            .map { TransactionHistoryViewModel.Action.itemSelected($0) }
            .bind(to: self.viewModel.didActionSubject)
            .disposed(by: self.disposeBag)
    }
    
    func setUpShouldPresentObservers() {
        self.viewModel.shouldPresent.asObservable()
            .subscribe(onNext: { [weak self] viewToPresent in
                switch viewToPresent {
                case .emptyResult(let emptyViewModel):
                    self?.prepareToDisplayEmptyView(emptyViewModel)
                case .transactionDetailController(let transactionDetailViewModel):
                    let listTableViewController = ListTableViewController(transactionDetailViewModel)
                    let bottomSheet = BottomSheetListViewController(contentViewController: listTableViewController)
                    self?.present(bottomSheet, animated: true, completion: nil)
                }
            }) ~ self.disposeBag
    }
}
