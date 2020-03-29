//
//  BottomMenuViewController.swift
//  SereyIO
//
//  Created by Panha Uy on 3/24/20.
//  Copyright © 2020 Phanha Uy. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift
import RxBinding
import RxDataSources

class BottomMenuViewController: BaseViewController {
    
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var tableView: ContentSizedTableView!
    
    var viewModel: BottomMenuViewModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setUpViews()
        setUpRxObservers()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        containerView.roundCorners(corners: [.topLeft, .topRight], radius: 8)
    }
}

// MARK: - Preparations & Tools
extension BottomMenuViewController {
    
    func setUpViews() {
        prepareTableView()
    }
    
    func prepareTableView() {
        self.tableView.tableFooterView = UIView()
        self.tableView.separatorStyle = .none
        self.tableView.register(ImageTextTableViewCell.self)
    }
}

// MARK: - SetUp RxObservers
extension BottomMenuViewController {
    
    func setUpRxObservers() {
        setUpContentChangedObservers()
    }
    
    func setUpContentChangedObservers() {
        self.viewModel.cells.asObservable()
            .bind(to: self.tableView.rx.items) { tableView, index, item in
                switch item {
                case is ImageTextCellViewModel:
                    let cell: ImageTextTableViewCell = tableView.dequeueReusableCell(forIndexPath: IndexPath(row: index, section: 0))
                    cell.cellModel = item as? ImageTextCellViewModel
                    return cell
                default:
                    return UITableViewCell()
                }
            } ~ self.disposeBag
        
        // Item Selected
        self.tableView.rx.itemSelected.asObservable()
            .`do`(onNext: { [weak self] indexPath in
                self?.tableView.deselectRow(at: indexPath, animated: true)
            })
            .map { BottomMenuViewModel.Action.itemSelected($0) }
            ~> self.viewModel.didActionSubject
            ~ self.disposeBag
    }
}
