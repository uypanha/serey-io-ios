//
//  PostTableViewController.swift
//  iOSTemplate
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
    
    fileprivate lazy var loadingContainerView: UIView = { [unowned self] in
        let containerView = UIView().then {
            $0.addSubview(self.loadingIndicatorView)
        }
        
        self.loadingIndicatorView.snp.makeConstraints({ make in
            make.width.height.equalTo(40)
            make.center.equalTo(containerView)
        })
        
        return containerView
    }()
    
    fileprivate lazy var loadingIndicatorView: NVActivityIndicatorView = {
        return NVActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 48, height: 48), type: .ballBeat, color: UIColor.lightGray.withAlphaComponent(0.5), padding: 0)
    }()
    
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
        self.tableView.separatorStyle = .none
        self.tableView.register(PostTableViewCell.self)
    }
    
    func prepreDataSource() -> RxTableViewSectionedReloadDataSource<SectionItem> {
        let dataSource = RxTableViewSectionedReloadDataSource<SectionItem>(configureCell: { (datasource, tableView, indexPath, item) -> UITableViewCell in
            switch item {
            case is PostCellViewModel:
                let cell: PostTableViewCell = tableView.dequeueReusableCell(forIndexPath: indexPath)
//                cell.cellModel = item as? PostCellViewModel
                return cell
//            case is LoadingCellViewModel:
//                let cell: LoadingTableViewCell = tableView.dequeueReusableCell(forIndexPath: indexPath)
//                return cell
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
        
        // Item Selected
//        self.tableView.rx.itemSelected.asObservable()
//            .map { SearchViewModel.Action.itemSelected(at: $0) }
//            .bind(to: self.viewModel.didActionSubject)
//            .disposed(by: self.disposeBag)
    }
}
