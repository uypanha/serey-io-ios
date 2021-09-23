//
//  VoterListViewModel.swift
//  SereyIO
//
//  Created by Panha Uy on 5/17/20.
//  Copyright © 2020 Serey IO. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift
import RxBinding
import RxDataSources

class VoterListViewModel: BaseListTableViewModel {
    
    let voters: BehaviorRelay<[PeopleModel]>
    let shouldShowUserAccount: PublishSubject<UserAccountViewModel>
    
    init(_ voters: [PeopleModel]) {
        self.voters = BehaviorRelay(value: voters)
        self.shouldShowUserAccount = PublishSubject()
        super.init([], true)
        
        setUpRxObservers()
    }
    
    override func registerTableViewCell(_ tableView: UITableView) {
        tableView.register(PeopleTableViewCell.self)
    }
    
    override func configureCell(_ datasource: TableViewSectionedDataSource<SectionItem>, _ tableView: UITableView, _ indexPath: IndexPath, _ item: CellViewModel) -> UITableViewCell {
        switch item {
        case is PeopleCellViewModel:
            let cell: PeopleTableViewCell = tableView.dequeueReusableCell(forIndexPath: indexPath)
            cell.cellModel = item as? PeopleCellViewModel
            return cell
        default:
            return super.configureCell(datasource, tableView, indexPath, item)
        }
    }
}

// MARK: - Preaparations & Tools
extension VoterListViewModel {
    
    func prepareCells(_ voters: [PeopleModel]) -> [SectionItem] {
        let cells = voters.map { PeopleCellViewModel($0) }
        return [SectionItem(items: cells)]
    }
}

// MARK: - Action Handlers
fileprivate extension VoterListViewModel {
    
    func handleItemSelected(_ indexPath: IndexPath) {
        if let item = self.item(at: indexPath) as? PeopleCellViewModel, let authorName = item.people.value {
            let userAccountViewModel = UserAccountViewModel(authorName)
            self.shouldShowUserAccount.onNext(userAccountViewModel)
            self.shouldDismiss.onNext(true)
        }
    }
}

// MARK: - SetUp RxObservers
extension VoterListViewModel {
    
    func setUpRxObservers() {
        setUpContentChangedObservers()
    }
    
    func setUpContentChangedObservers() {
        self.voters.asObservable()
            .map { self.prepareCells($0) }
            ~> self.cells
            ~ self.disposeBag
        
        self.itemSelected.asObservable()
            .subscribe(onNext: { [weak self] indexPath in
                self?.handleItemSelected(indexPath)
            }) ~ self.disposeBag
    }
}
