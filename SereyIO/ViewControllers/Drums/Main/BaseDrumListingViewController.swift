//
//  BaseDrumListingViewController.swift
//  SereyIO
//
//  Created by Panha Uy on 14/7/22.
//  Copyright © 2022 Serey IO. All rights reserved.
//

import UIKit
import Then
import SnapKit
import RxCocoa
import RxSwift
import RxBinding
import RxDataSources

class BaseDrumListingViewController: BaseTableViewController {

    lazy var dataSource: RxTableViewSectionedReloadDataSource<SectionItem> = { [unowned self] in
        return self.prepreDataSource()
    }()
    
    var viewModel: BrowseDrumsViewModel!
    
    init(viewModel: BrowseDrumsViewModel) {
        super.init(nibName: nil, bundle: nil)
        
        self.viewModel = viewModel
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setUpViews()
        setUpRxObservers()
        DispatchQueue.main.async {
            self.viewModel.downloadData()
        }
    }
}

// MARK: - Preparations & Tools
extension BaseDrumListingViewController {
    
    func setUpViews() {
        self.view.backgroundColor = .color("#FAFAFA")
        setUpTableView()
    }
    
    func setUpTableView() {
        self.tableView.separatorStyle = .none
        self.tableView.contentInset = .init(top: 8, left: 0, bottom: 8, right: 0)
        
        self.tableView.register(PostDrumsTableViewCell.self, isNib: false)
        self.tableView.register(DrumsPostTableViewCell.self, isNib: false)
        self.tableView.register(NoMorePostTableViewCell.self, isNib: false)
    }
    
    func prepreDataSource() -> RxTableViewSectionedReloadDataSource<SectionItem> {
        let dataSource = RxTableViewSectionedReloadDataSource<SectionItem>(configureCell: { (datasource, tableView, indexPath, item) -> UITableViewCell in
            switch item {
            case is PostDrumsCellViewModel:
                let cell: PostDrumsTableViewCell = tableView.dequeueReusableCell(forIndexPath: indexPath)
                return cell
            case is DrumsPostCellViewModel:
                let cell: DrumsPostTableViewCell = tableView.dequeueReusableCell(forIndexPath: indexPath)
                cell.cellModel = item as? DrumsPostCellViewModel
                return cell
            case is NoMorePostCellViewModel:
                let cell: NoMorePostTableViewCell = tableView.dequeueReusableCell(forIndexPath: indexPath)
                cell.cellModel = item as? NoMorePostCellViewModel
                return cell
            default:
                return UITableViewCell()
            }
        })
        
        return dataSource
    }
    
}

// MARK: - SetUp RxObservers
extension BaseDrumListingViewController {
    
    func setUpRxObservers() {
        setUpControlObservers()
        setContentChangedObservers()
        setUpViewToPresentObservers()
    }
    
    func setUpControlObservers() {
        self.tableView.rx.willDisplayCell.asObservable()
            .subscribe(on: MainScheduler.asyncInstance)
            .subscribe(onNext: { [weak self] cell, indexPath in
                if self?.viewModel.isLastItem(indexPath: indexPath) == true {
                    self?.viewModel.downloadData()
                }
            }) ~ self.disposeBag
        
        self.tableView.rx.itemSelected.asObservable()
            .map { BrowseDrumsViewModel.Action.itemSelected($0) }
            ~> self.viewModel.didActionSubject
            ~ self.disposeBag
    }
    
    func setContentChangedObservers() {
        self.viewModel.cells.asObservable()
            .bind(to: self.tableView.rx.items(dataSource: self.dataSource))
            .disposed(by: self.disposeBag)
    }
    
    func setUpViewToPresentObservers() {
        self.viewModel.shouldPresent.asObservable()
            .subscribe(onNext: { [weak self] viewToPresent in
                switch viewToPresent {
                case .postDrumViewController:
                    let postDrumViewController = PostDrumViewController()
                    let nv = CloseableNavigationController(rootViewController: postDrumViewController)
                    self?.present(nv, animated: true)
                case .authorDrumListingViewController(let viewModel):
                    let authorDrumListViewController = AuthorDrumListViewController(viewModel: viewModel)
                    self?.show(authorDrumListViewController, sender: nil)
                }
            }) ~ self.disposeBag
    }
}
