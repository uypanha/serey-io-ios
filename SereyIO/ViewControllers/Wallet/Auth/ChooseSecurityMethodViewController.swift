//
//  ChooseSecurityMethodViewController.swift
//  SereyIO
//
//  Created by Panha Uy on 6/15/20.
//  Copyright © 2020 Phanha Uy. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift
import RxDataSources
import RxBinding

class ChooseSecurityMethodViewController: BaseViewController {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var tableView: ContentSizedTableView!
    @IBOutlet weak var userLaterButton: UIButton!
    
    @IBOutlet weak var tableViewHeightConstraint: NSLayoutConstraint!
    
    var viewModel: ChooseSecurityMethodViewModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setUpViews()
        setUpRxObservers()
    }
    
    override func setUpLocalizedTexts() {
        super.setUpLocalizedTexts()
        
        // Do any addtional setup texts after view will display
    }
}

// MARK: - Preparations & Tools
extension ChooseSecurityMethodViewController {
    
    func setUpViews() {
        prepareTableView()
        
        self.userLaterButton.primaryStyle()
    }
    
    func prepareTableView() {
        self.tableView.tableFooterView = UIView()
        self.tableView.separatorStyle = .none
        self.tableView.register(SecurityMethodeTableViewCell.self)
    }
}

// MARK: - SetUp RxObservers
extension ChooseSecurityMethodViewController {
    
    func setUpRxObservers() {
        setUpContentChangedObservers()
        setUpControlObservers()
        setUpShouldPresentObservers()
    }
    
    func setUpContentChangedObservers() {
        self.viewModel.cells.asObservable()
            .bind(to: self.tableView.rx.items) { tableView, index, item in
                switch item {
                case is SecurityMethodCellViewModel:
                    let cell: SecurityMethodeTableViewCell = tableView.dequeueReusableCell(forIndexPath: IndexPath(row: index, section: 0))
                    cell.cellModel = item as? SecurityMethodCellViewModel
                    return cell
                default:
                    return UITableViewCell()
                }
            } ~ self.disposeBag
    }
    
    func setUpControlObservers() {
        self.tableView.rx.itemSelected.asObservable()
            .`do`(onNext: { [weak self] indexPath in
                self?.tableView.deselectRow(at: indexPath, animated: true)
            })
            .map { ChooseSecurityMethodViewModel.Action.itemSelected($0) }
            ~> self.viewModel.didActionSubject
            ~ self.disposeBag
    }
    
    func setUpShouldPresentObservers() {
        self.viewModel.shouldPresent.asObservable()
            .subscribe(onNext: { [weak self] viewToPresent in
                switch viewToPresent {
                case .activeBiometryController(let activeBiometryViewModel):
                    if let activeBiometryController = R.storyboard.biometry.activeBiometryViewController() {
                        activeBiometryController.viewModel = activeBiometryViewModel
                        self?.show(activeBiometryController, sender: nil)
                    }
                }
            }) ~ self.disposeBag
    }
}
