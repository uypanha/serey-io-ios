//
//  ReplyCommentViewController.swift
//  SereyIO
//
//  Created by Panha Uy on 4/14/20.
//  Copyright © 2020 Phanha Uy. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift
import RxBinding
import RxDataSources

class ReplyCommentViewController: BaseViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var commentTextView: CommentTextView!
    @IBOutlet weak var commentContainerView: UIView!
    
    var viewModel: ReplyCommentTableViewModel!
    
    lazy var dataSource: RxTableViewSectionedReloadDataSource<SectionItem> = { [unowned self] in
        return self.prepreDataSource()
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        setUpViews()
        setUpRxObservers()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.showNavigationBarBorder()
    }
    
    func prepreDataSource() -> RxTableViewSectionedReloadDataSource<SectionItem> {
        let dataSource = RxTableViewSectionedReloadDataSource<SectionItem>(configureCell: { (datasource, tableView, indexPath, item) -> UITableViewCell in
            switch item {
            case is CommentCellViewModel:
                let cell: CommentTableViewCell = tableView.dequeueReusableCell(forIndexPath: indexPath)
                cell.cellModel = item as? CommentCellViewModel
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
extension ReplyCommentViewController {
    
    func setUpViews() {
        self.title = "Replies"
        self.tableView.refreshControl = UIRefreshControl()
        self.commentContainerView.addBorders(edges: [.top], color: ColorName.border.color, thickness: 1)
        prepareTableView()
    }
    
    func prepareTableView() {
        self.tableView.tableFooterView = UIView()
        self.tableView.separatorStyle = .none
        self.tableView.register(CommentTableViewCell.self)
    }
}

// MARK: - SetUp RxObservers
fileprivate extension ReplyCommentViewController {
    
    func setUpRxObservers() {
        setUpContentChangedObsesrvers()
        setUpTableViewObservers()
    }
    
    func setUpContentChangedObsesrvers() {
        self.commentTextView.viewModel = self.viewModel.commentViewModel
    }
    
    func setUpTableViewObservers() {
        self.viewModel.cells.asObservable()
            ~> self.tableView.rx.items(dataSource: self.dataSource)
            ~ self.disposeBag
        
        // Item Selected
//        self.tableView.rx.itemSelected.asObservable()
//            .bind(to: viewModel.itemSelected)
//            ~ self.disposeBag
    }
}
