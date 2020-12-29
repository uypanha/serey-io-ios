//
//  DraftListViewModel.swift
//  SereyIO
//
//  Created by Panha Uy on 12/24/20.
//  Copyright © 2020 Phanha Uy. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift
import RxDataSources
import RealmSwift
import RxRealm
import RxBinding

class DraftListViewModel: BaseListTableViewModel, ShouldPresent {
    
    enum ViewToPresent {
        case editDraftController(CreatePostViewModel)
    }
    
    // output:
    let shouldPresentSubject: PublishSubject<ViewToPresent>
    
    let drafts: Results<DraftModel>
    
    init() {
        self.drafts = DraftModel().queryAll()
        self.shouldPresentSubject = .init()
        super.init([])
        
        setUpRxObservers()
    }
    
    override func registerTableViewCell(_ tableView: UITableView) {
        super.registerTableViewCell(tableView)
        
        tableView.separatorStyle = .none
        tableView.register(DraftTableViewCell.self)
        tableView.register(TextTableViewCell.self)
    }
    
    override func configureCell(_ datasource: TableViewSectionedDataSource<SectionItem>, _ tableView: UITableView, _ indexPath: IndexPath, _ item: CellViewModel) -> UITableViewCell {
        switch item {
        case is DraftCellViewModel:
            let cell: DraftTableViewCell = tableView.dequeueReusableCell(forIndexPath: indexPath)
            cell.cellModel = item as? DraftCellViewModel
            return cell
        case is TextCellViewModel:
            let cell: TextTableViewCell = tableView.dequeueReusableCell(forIndexPath: indexPath)
            cell.cellModel = item as? TextCellViewModel
            return cell
        default:
            return super.configureCell(datasource, tableView, indexPath, item)
        }
    }
}

// MARK: - Preparations & Tools
extension DraftListViewModel {
    
    func prepareCells(_ drafts: [DraftModel]) -> [SectionItem] {
        var items: [CellViewModel] = [self.prepareTitleCellModel()]
        items.append(contentsOf: drafts.map { DraftCellViewModel($0).then { self.setUpCellObservers($0) } })
        return [SectionItem(items: items)]
    }
    
    private func prepareTitleCellModel() -> CellViewModel {
        let properties = TextLabelProperties(font: UIFont.systemFont(ofSize: 22, weight: .semibold), textColor: .black, backgroundColor: .clear, alignment: .left)
        return TextCellViewModel(with: "Your draft articles", properties: properties, indicatorAccessory: false, isSelectionEnabled: false)
    }
    
    private func handleItemSelected(_ indexPath: IndexPath) {
        if let item = self.item(at: indexPath) as? DraftCellViewModel {
            let editDraftViewModel = CreatePostViewModel(.draft(item.draft.value))
            self.shouldPresent(.editDraftController(editDraftViewModel))
        }
    }
}

// MARK: - SetUp RxObservers
extension DraftListViewModel {
    
    func setUpRxObservers() {
        setUpContentChangedObservers()
    }
    
    func setUpContentChangedObservers() {
        Observable.array(from: self.drafts)
            .asObservable()
            .map { self.prepareCells($0) }
            ~> self.cells
            ~ self.disposeBag
        
        self.itemSelected.asObservable()
            .subscribe(onNext: { [weak self] indexPath in
                self?.handleItemSelected(indexPath)
            }) ~ self.disposeBag
    }
    
    func setUpCellObservers(_ cellModel: DraftCellViewModel) {
        cellModel.continuteEditDraft.asObservable()
            .subscribe(onNext: { [weak self] draftModel in
                let editDraftViewModel = CreatePostViewModel(.draft(draftModel))
                self?.shouldPresent(.editDraftController(editDraftViewModel))
            }) ~ cellModel.disposeBag
    }
}
