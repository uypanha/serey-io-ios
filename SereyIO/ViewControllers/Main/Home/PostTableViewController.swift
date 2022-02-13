//
//  PostTableViewController.swift
//  SereyIO
//
//  Created by Phanha Uy on 2/6/20.
//  Copyright © 2020 Serey IO. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift
import RxBinding
import RxDataSources
import NVActivityIndicatorView
import SnapKit
import Then

class PostTableViewController: BaseTableViewController, AlertDialogController {
    
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
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if viewModel.shouldRefresh {
            viewModel.shouldRefresh = false
            self.refreshControl?.beginRefreshing()
            self.viewModel.didAction(with: .refresh)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.viewModel.validateCountry()
    }
    
    func setUpRxObservers() {
        setUpControlsObsservers()
        setUpContentChangedObservers()
        shouldPresentObservers()
        setUpShouldPresentErrorObservers()
    }
}

// MARK: - Preparations & Tools
fileprivate extension PostTableViewController {
    
    func setUpViews() {
        prepareTableView()
    }
    
    func prepareTableView() {
        self.refreshControl = UIRefreshControl()
        self.tableView.backgroundColor = ColorName.postBackground.color
        self.tableView.tableFooterView = UIView()
        self.tableView.register(PostTableViewCell.self)
        self.tableView.register(FilteredCategoryTableViewCell.self)
        self.tableView.register(DraftSavedTableViewCell.self)
        self.tableView.register(UndoHiddenPostTableViewCell.self, isNib: false)
    }
    
    func prepreDataSource() -> RxTableViewSectionedReloadDataSource<SectionItem> {
        let dataSource = RxTableViewSectionedReloadDataSource<SectionItem>(configureCell: { (datasource, tableView, indexPath, item) -> UITableViewCell in
            switch item {
            case is PostCellViewModel:
                let cell: PostTableViewCell = tableView.dequeueReusableCell(forIndexPath: indexPath)
                cell.cellModel = item as? PostCellViewModel
                return cell
            case is FilteredCategoryCellViewModel:
                let cell: FilteredCategoryTableViewCell = tableView.dequeueReusableCell(forIndexPath: indexPath)
                cell.cellModel = item as? FilteredCategoryCellViewModel
                cell.layoutIfNeeded()
                return cell
            case is DraftSavedCellViewModel:
                let cell: DraftSavedTableViewCell = tableView.dequeueReusableCell(forIndexPath: indexPath)
                cell.cellModel = item as? DraftSavedCellViewModel
                return cell
            case is UndoHiddenPostCellViewModel:
                let cell: UndoHiddenPostTableViewCell = tableView.dequeueReusableCell(forIndexPath: indexPath)
                cell.cellModel = item as? UndoHiddenPostCellViewModel
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
    
    func setUpControlsObsservers() {
        self.refreshControl?.rx.controlEvent(.valueChanged)
            .filter { return self.refreshControl!.isRefreshing }
            .map { PostTableViewModel.Action.refresh }
            .bind(to: self.viewModel.didActionSubject)
            .disposed(by: self.disposeBag)
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
            ~ self.disposeBag
        
        self.viewModel.endRefresh.asObservable()
            .subscribe(onNext: { [weak self] endRefreshing in
                if endRefreshing {
                    self?.tableView.refreshControl?.endRefreshing()
                }
            }) ~ self.disposeBag
        
        self.viewModel.emptyOrError.asObservable()
            .subscribe(onNext: { [weak self] emptyOrErrorViewModel in
                if let emptyOrErrorViewModel = emptyOrErrorViewModel {
                    self?.prepareToDisplayEmptyView(emptyOrErrorViewModel)
                }
            }) ~ self.disposeBag
        
        // Item Selected
        self.tableView.rx.itemSelected.asObservable()
            .map { PostTableViewModel.Action.itemSelected($0) }
            .bind(to: self.viewModel.didActionSubject)
            ~ self.disposeBag
        
        self.tableView.rx.willDisplayCell.asObservable()
            .subscribe(onNext: { [unowned self] (cell, indexPath) in
                if self.viewModel.isLastItem(indexPath: indexPath) {
                    self.viewModel.downloadData()
                }
            }) ~ self.disposeBag
    }
    
    func shouldPresentObservers() {
        self.viewModel.shouldPresent.asObservable()
            .subscribe(onNext: { viewToPresent in
                switch viewToPresent {
                case .moreDialogController(let bottomViewModel):
                    let bottomMenuController = BottomMenuViewController(bottomViewModel)
                    self.present(bottomMenuController, animated: true, completion: nil)
                case .deletePostDialog(let confirm):
                    self.showDialog(nil, title: R.string.post.deleteArticleQ.localized(), message: R.string.post.deleteArticleMessage.localized(), dismissable: false, positiveButton: R.string.common.delete.localized(), positiveCompletion: {
                        confirm()
                    }, negativeButton: R.string.common.no.localized())
                default:
                    break
                }
            }) ~ self.disposeBag
    }
    
    func setUpShouldPresentErrorObservers() {
        self.viewModel.shouldPresentError.asObservable()
            .subscribe(onNext: { [unowned self] errorInfo in
                if self.viewModel.discussions.value.isEmpty {
                    self.prepareToDisplayEmptyView(self.viewModel.prepareEmptyViewModel(errorInfo))
                } else {
                    self.showDialogError(errorInfo, positiveButton: R.string.common.tryAgain.localized(), positiveCompletion: {
                        self.viewModel.downloadData()
                    }, negativeButton: R.string.common.cancel.localized())
                }
            }) ~ self.disposeBag
    }
}
