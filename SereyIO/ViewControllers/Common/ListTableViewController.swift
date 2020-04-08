//
//  ListTableViewController.swift
//  SereyIO
//
//  Created by Panha Uy on 3/30/20.
//  Copyright © 2020 Phanha Uy. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift
import RxBinding
import RxDataSources

class ListTableViewController<T>: BaseTableViewController where T : BaseListTableViewModel {
    
    let viewModel: T
    var sepereatorStyle: UITableViewCell.SeparatorStyle = .singleLine
    var contentInset: UIEdgeInsets = UIEdgeInsets.zero
    
    lazy var dataSource: RxTableViewSectionedReloadDataSource<SectionItem> = { [unowned self] in
        return self.prepreDataSource()
    }()
    
    init(_ viewModel: T, _ style: UITableView.Style = .plain) {
        self.viewModel = viewModel
        super.init(style: style)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setUpView()
        setUpRxObservers()
        viewModel.downloadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if self.viewModel.showBorder {
            self.navigationController?.showNavigationBarBorder()
        } else {
            self.navigationController?.removeNavigationBarBorder()
        }
    }
    
    open func setUpView() {
        self.tableView.tableFooterView = UIView()
        self.tableView.separatorStyle = self.sepereatorStyle
        self.tableView.contentInset = self.contentInset
        self.viewModel.registerTableViewCell(self.tableView)
    }
    
    open func prepreDataSource() -> RxTableViewSectionedReloadDataSource<SectionItem> {
        return self.viewModel.prepareDatasource()
    }
}

// MARK: - SetUp RxObservers
fileprivate extension ListTableViewController {
    
    func setUpRxObservers() {
        setUpTableViewObservers()
    }
    
    func setUpTableViewObservers() {
        self.viewModel.cells.asObservable()
            ~> self.tableView.rx.items(dataSource: self.dataSource)
            ~ self.disposeBag
        
        // Item Selected
        self.tableView.rx.itemSelected.asObservable()
            .map { T.Action.itemSelected($0) }
            .bind(to: self.viewModel.didActionSubject)
            ~ self.disposeBag
        
        self.viewModel.shouldDismiss.asObservable()
            .subscribe(onNext: { [weak self] dismiss in
                if dismiss {
                    if self?.navigationController != nil {
                        self?.navigationController?.popViewController(animated: true)
                    } else {
                        self?.dismiss(animated: true, completion: nil)
                    }
                }
            }) ~ self.disposeBag
    }
}
