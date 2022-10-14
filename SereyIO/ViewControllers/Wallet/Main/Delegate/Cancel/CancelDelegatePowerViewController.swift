//
//  CancelDelegatePowerViewController.swift
//  SereyIO
//
//  Created by Panha Uy on 12/10/22.
//  Copyright © 2022 Serey IO. All rights reserved.
//

import UIKit
import Then
import SnapKit
import RxCocoa
import RxSwift
import RxBinding

class CancelDelegatePowerViewController: BaseViewController, AlertDialogController, LoadingIndicatorController {
    
    lazy var headerView: TransactionHeaderView = {
        return .init()
    }()
    
    lazy var contentView: UIView = {
        return .init().then {
            $0.backgroundColor = .white
        }
    }()
    
    lazy var tableView: UITableView = {
        return .init(frame: .init(), style: .plain).then {
            $0.backgroundColor = .clear
            $0.tableFooterView = .init()
            
            $0.contentInset = .init(top: 16, left: 0, bottom: 16, right: 0)
            $0.register(DelegatedUserTableViewCell.self, isNib: false)
        }
    }()
    
    var emptyView: EmptyOrErrorView? {
        didSet {
            self.tableView.backgroundView = emptyView
        }
    }
    
    var viewModel: CancelDelegatePowerViewModel!
    
    override func loadView() {
        self.view = self.prepareViews()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setUpRxObservers()
        self.viewModel.downloadData()
    }
    
    override func setUpLocalizedTexts() {
        super.setUpLocalizedTexts()
        
        self.headerView.titleLabel.text = "Cancel Delegation"
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.setNavigationBarColor(.color(.primary), tintColor: .white)
        self.navigationController?.removeNavigationBarBorder()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        self.contentView.roundCorners(corners: [.topLeft, .topRight], radius: 12)
    }
}

// MARK: - Preparations & Tools
extension CancelDelegatePowerViewController {
    
    func prepareToShowEmptyView(with emptyViewModel: EmptyOrErrorViewModel?) {
        self.emptyView?.removeFromSuperview()
        self.emptyView = nil
        if let emptyViewModel = emptyViewModel {
            self.emptyView = .init()
            self.emptyView?.viewModel = emptyViewModel
        }
    }
}

// MARK: - SetUp RxObservers
private extension CancelDelegatePowerViewController {
    
    func setUpRxObservers() {
        setUpContentChangedObservers()
        setUpViewToPresentObservers()
        setUpShouldPresentErrorObservers()
    }
    
    func setUpContentChangedObservers() {
        self.viewModel.cells.asObservable()
            .bind(to: self.tableView.rx.items) { tableView, index, item in
                let indexPath = IndexPath(row: index, section: 0)
                switch item {
                case is DelegatedUserCellViewModel:
                    let cell: DelegatedUserTableViewCell = tableView.dequeueReusableCell(forIndexPath: indexPath)
                    cell.cellModel = item as? DelegatedUserCellViewModel
                    return cell
                default:
                    return .init()
                }
            } ~ self.disposeBag
        
        self.viewModel.shouldShowEmptyView.asObservable()
            .subscribe(onNext: { [weak self] emptyViewModel in
                self?.prepareToShowEmptyView(with: emptyViewModel)
            }) ~ self.disposeBag
    }
    
    func setUpViewToPresentObservers() {
        self.viewModel.shouldPresent.asObservable()
            .subscribe(onNext: { [weak self] viewToPresent in
                switch viewToPresent {
                case .loading(let loading):
                    loading ? self?.showLoading() : self?.dismissLoading()
                case .showAlertDialogController(let alertDialogModel):
                    self?.showDialog(alertDialogModel)
                case .confirmCancelDelegateController(let viewModel):
                    let confirmCancelDelegateViewController = ConfirmDialogViewController(viewModel)
                    let bottomSheet = BottomSheetViewController(contentViewController: confirmCancelDelegateViewController)
                    self?.present(bottomSheet, animated: true, completion: nil)
                }
            }) ~ self.disposeBag
    }
    
    func setUpShouldPresentErrorObservers() {
        self.viewModel.shouldPresentError.asObservable()
            .subscribe(onNext: { [weak self] errorInfo in
                if self?.viewModel.isEmpty() == true {
                    let emptyViewModel = EmptyOrErrorViewModel(withErrorEmptyModel: .init(withErrorInfo: errorInfo, actionTitle: "Retry".localize(), actionCompletion: {
                        self?.viewModel.downloadData()
                    }))
                    self?.prepareToShowEmptyView(with: emptyViewModel)
                } else {
                    self?.showDialogError(errorInfo)
                }
            }) ~ self.disposeBag
    }
}
