//
//  NotificationSettingsViewController.swift
//  SereyIO
//
//  Created by Panha Uy on 4/27/20.
//  Copyright © 2020 Phanha Uy. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift
import RxDataSources

class NotificationSettingsViewController: BaseViewController {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var tableView: ContentSizedTableView!
    
    lazy var dataSource: RxTableViewSectionedReloadDataSource<SectionItem> = { [unowned self] in
        return self.prepreDataSource()
    }()
    
    var viewModel: NotificationSettingsViewModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setUpViews()
        setUpRxObservers()
    }
}

// MARK: - Preparations & Tools
extension NotificationSettingsViewController {
    
    func setUpViews() {
        preapreTableView()
    }
    
    func preapreTableView() {
        self.tableView.tableFooterView = UIView()
        self.tableView.separatorStyle = .none
        
        self.tableView.register(ToggleTextTableViewCell.self)
    }
    
    func prepreDataSource() -> RxTableViewSectionedReloadDataSource<SectionItem> {
        let dataSource = RxTableViewSectionedReloadDataSource<SectionItem>(configureCell: { (dataSource, tableView, indexPath, item) -> UITableViewCell in
            switch item {
            case is ToggleTextCellModel:
                let cell: ToggleTextTableViewCell = tableView.dequeueReusableCell(forIndexPath: indexPath)
                cell.cellModel = item as? ToggleTextCellModel
                return cell
            default:
                return UITableViewCell()
            }
        })
        
        return dataSource
    }
}

// MARK: - SetUP RxObservers
fileprivate extension NotificationSettingsViewController {
    
    func setUpRxObservers() {
        setUpTableViewObservers()
        setUpShouldPresentObservers()
    }
    
    func setUpTableViewObservers() {
        self.viewModel.cells.asObservable()
            .bind(to: self.tableView.rx.items(dataSource: self.dataSource))
            .disposed(by: self.disposeBag)
        
//        self.tableView.rx.itemSelected.asObservable()
//            .`do`(onNext: {[weak self] in self?.tableView.deselectRow(at: $0, animated: true) })
//            .map { ChooseLanguageViewModel.Action.itemSelected(at: $0) }
//            .bind(to: self.viewModel.didActionSubject)
//            .disposed(by: self.disposeBag)
    }
    
    func setUpShouldPresentObservers() {
    }
}

