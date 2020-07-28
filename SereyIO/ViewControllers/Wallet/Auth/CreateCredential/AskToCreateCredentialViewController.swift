//
//  AskToCreateCredentialViewController.swift
//  SereyIO
//
//  Created by Panha Uy on 7/26/20.
//  Copyright © 2020 Phanha Uy. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift
import RxBinding

class AskToCreateCredentialViewController: BaseViewController {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var tableView: ContentSizedTableView!
    @IBOutlet weak var skipButton: UIButton!
    
    var viewModel: AskToCreateCredentialViewModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        setUpViews()
        setUpRxObservers()
    }
}

// MARK: - Preparations & Tools
extension AskToCreateCredentialViewController {
    
    func setUpViews() {
        prepareTableView()
        self.skipButton.primaryStyle()
    }
    
    func prepareTableView() {
        self.tableView.tableFooterView = UIView()
        self.tableView.separatorStyle = .none
        self.tableView.delegate = self
        
        self.tableView.register(CreateCredentialTableViewCell.self)
    }
}

// MARK: - UITableView Datasource
extension AskToCreateCredentialViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        self.viewModel.didAction(with: .itemSelected(indexPath))
    }
}

// MARK: - SetUp RxObservers
extension AskToCreateCredentialViewController {
    
    func setUpRxObservers() {
        setUpContentChangedObservers()
        setUpControlObservers()
        setUpViewToPresentObservers()
    }
    
    func setUpContentChangedObservers() {
        self.viewModel.cells.asObservable()
            .bind(to: self.tableView.rx.items) { tableView, index, item in
                switch item {
                case is CreateCredentialCellViewModel:
                    let cell: CreateCredentialTableViewCell = tableView.dequeueReusableCell(forIndexPath: IndexPath(row: index, section: 0))
                    cell.cellModel = item as? CreateCredentialCellViewModel
                    return cell
                default:
                    return UITableViewCell()
                }
            } ~ self.disposeBag
    }
    
    func setUpControlObservers() {
        self.skipButton.rx.tap.asObservable()
            .map { AskToCreateCredentialViewModel.Action.skipPressed }
            ~> self.viewModel.didActionSubject
            ~ self.disposeBag
    }
    
    func setUpViewToPresentObservers() {
        self.viewModel.shouldPresent.asObservable()
            .subscribe(onNext: { viewToPresent in
                switch viewToPresent {
                case .setUpSecurityMethodController:
                    SereyWallet.shared?.rootViewController.switchToChooseSecurityMethod()
                case .createCredentialViewController:
                    SereyWallet.shared?.rootViewController.switchToCreateCredential()
                }
            }) ~ self.disposeBag
    }
}
