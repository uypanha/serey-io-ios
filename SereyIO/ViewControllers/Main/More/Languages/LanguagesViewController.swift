//
//  LanguagesViewController.swift
//  SereyIO
//
//  Created by Phanha Uy on 2/10/20.
//  Copyright © 2020 Serey IO. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift
import RxDataSources

class LanguagesViewController: BaseTableViewController {
    
    lazy var dataSource: RxTableViewSectionedReloadDataSource<SectionItem> = { [unowned self] in
        return self.prepreDataSource()
    }()
    
    var viewModel: ChooseLanguageViewModel!
    
    override init(style: UITableView.Style = .plain) {
        super.init(style: style)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.showNavigationBarBorder()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setUpViews()
        setUpRxObservers()
    }
    
    override func setUpLocalizedTexts() {
        super.setUpLocalizedTexts()
        prepareStringResources()
    }
}

// MARK: - Preparations & Tools
fileprivate extension LanguagesViewController {
    
    func setUpViews() {
        prepareStringResources()
        prepareTableView()
    }
    
    func prepareStringResources() {
        self.title = R.string.settings.languages.localized()
    }
    
    func prepareTableView() {
        self.tableView.separatorStyle = .none
        self.tableView.tableFooterView = UIView()
        self.tableView.register(LanguageTableViewCell.self)
    }
    
    func prepreDataSource() -> RxTableViewSectionedReloadDataSource<SectionItem> {
        let dataSource = RxTableViewSectionedReloadDataSource<SectionItem>(configureCell: { (dataSource, tableView, indexPath, item) -> UITableViewCell in
            switch item {
            case is LanguageCellViewModel:
                let cell: LanguageTableViewCell = tableView.dequeueReusableCell(forIndexPath: indexPath)
                cell.cellModel = item as? LanguageCellViewModel
                return cell
            default:
                return UITableViewCell()
            }
        })
        
        return dataSource
    }
}

// MARK: - SetUP RxObservers
fileprivate extension LanguagesViewController {
    
    func setUpRxObservers() {
        setUpTableViewObservers()
        setUpShouldPresentObservers()
    }
    
    func setUpTableViewObservers() {
        self.viewModel.cells.asObservable()
            .bind(to: self.tableView.rx.items(dataSource: self.dataSource))
            .disposed(by: self.disposeBag)
        
        self.tableView.rx.itemSelected.asObservable()
            .`do`(onNext: {[weak self] in self?.tableView.deselectRow(at: $0, animated: true) })
            .map { ChooseLanguageViewModel.Action.itemSelected(at: $0) }
            .bind(to: self.viewModel.didActionSubject)
            .disposed(by: self.disposeBag)
    }
    
    func setUpShouldPresentObservers() {
        self.viewModel.shouldPresent.asObservable()
            .subscribe(onNext: { [weak self] viewToPresent in
                switch viewToPresent {
                case .dismiss:
                    self?.navigationController?.popViewController(animated: true)
                }
            }).disposed(by: self.disposeBag)
    }
}
