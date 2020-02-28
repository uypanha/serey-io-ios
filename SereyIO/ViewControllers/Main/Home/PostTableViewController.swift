//
//  PostTableViewController.swift
//  SereyIO
//
//  Created by Phanha Uy on 2/6/20.
//  Copyright © 2020 Phanha Uy. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift
import RxBinding
import RxDataSources
import NVActivityIndicatorView
import SnapKit

class PostTableViewController: BaseTableViewController {
    
    fileprivate weak var emptyView: EmptyOrErrorView? = nil {
        didSet {
            self.tableView?.backgroundView = emptyView
        }
    }
    
    lazy var dataSource: RxTableViewSectionedReloadDataSource<SectionItem> = { [unowned self] in
        return self.prepreDataSource()
    }()
    
    var viewModel: PostTableViewModel!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setUpViews()
        setUpRxObservers()
        viewModel.downloadData()
    }
}

// MARK: - Preparations & Tools
fileprivate extension PostTableViewController {
    
    func setUpViews() {
        prepareTableView()
    }
    
    func prepareTableView() {
        self.tableView.backgroundColor = ColorName.postBackground.color
        self.tableView.tableFooterView = UIView()
        self.tableView.register(PostTableViewCell.self)
    }
    
    func prepreDataSource() -> RxTableViewSectionedReloadDataSource<SectionItem> {
        let dataSource = RxTableViewSectionedReloadDataSource<SectionItem>(configureCell: { (datasource, tableView, indexPath, item) -> UITableViewCell in
            switch item {
            case is PostCellViewModel:
                let cell: PostTableViewCell = tableView.dequeueReusableCell(forIndexPath: indexPath)
                cell.cellModel = item as? PostCellViewModel
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
    
    private func prepareToDisplayEmptyView(_ model: EmptyOrErrorViewModel) {
        let emptyView = EmptyOrErrorView()
        emptyView.viewModel = model
        self.emptyView = emptyView
    }
}

// MARK: - SetUp Rx Observers
fileprivate extension PostTableViewController {
    
    func setUpRxObservers() {
        setUpContentChangedObservers()
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
        
        self.viewModel.emptyOrError.asObservable()
            .subscribe(onNext: { [weak self] emptyOrErrorViewModel in
                if let emptyOrErrorViewModel = emptyOrErrorViewModel {
                    self?.prepareToDisplayEmptyView(emptyOrErrorViewModel)
                }
            }) ~ self.disposeBag
        
        // Item Selected
//        self.tableView.rx.itemSelected.asObservable()
//            .map { SearchViewModel.Action.itemSelected(at: $0) }
//            .bind(to: self.viewModel.didActionSubject)
//            .disposed(by: self.disposeBag)
        
        self.tableView.rx.willDisplayCell.asObservable()
            .subscribe(onNext: { [unowned self] (cell, indexPath) in
                if self.viewModel.isLastItem(indexPath: indexPath) {
                    self.viewModel.downloadData()
                }
            }) ~ self.disposeBag
    }
}
