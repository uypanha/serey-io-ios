//
//  ReportPostViewController.swift
//  SereyIO
//
//  Created by Mäd on 26/01/2022.
//  Copyright © 2022 Serey IO. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift
import RxBinding
import Then

class ReportPostViewController: BaseViewController, LoadingIndicatorController {
    
    lazy var titleLabel: UILabel = {
        return .createLabel(22, weight: .medium, textColor: .black)
    }()
    
    lazy var descriptionLabel: UILabel = {
        return .createLabel(14, weight: .regular, textColor: UIColor(hexString: "#606060")).then {
            $0.numberOfLines = 0
        }
    }()
    
    lazy var tableView: ContentSizedTableView = {
        return .init(frame: .init(), style: .plain).then {
            $0.contentInset = .zero
            $0.register(TextTableViewCell.self)
            $0.separatorStyle = .none
        }
    }()
    
    lazy var closeButton: UIBarButtonItem = {
        return .init(image: R.image.clearIcon(), style: .plain, target: nil, action: nil)
    }()
    
    var viewModel: ReportPostViewModel!
    
    override func loadView() {
        self.view = self.prepareViews()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setUpViews()
        setUpRxObservers()
        viewModel.downloadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.showNavigationBarBorder()
    }
    
    override func setUpLocalizedTexts() {
        self.title = "Report"
        self.titleLabel.text = "Please select a problem"
        self.descriptionLabel.text = "If someone is in imemediate danger, get help before reporting to Serey. Don’t settle."
    }
}

// MARK: - Preparations & Tools
extension ReportPostViewController {
    
    func setUpViews() {
        self.navigationItem.rightBarButtonItem = self.closeButton
    }
}

// MARK: - SetUp RxObservers
extension ReportPostViewController {
    
    func setUpRxObservers() {
        setUpControlObservers()
        setUpContentChangedObservers()
        setUpViewToPresentObservers()
    }
    
    func setUpControlObservers() {
        self.closeButton.rx.tap.asObservable()
            .subscribe(onNext: { [weak self] _ in
                self?.dismiss(animated: true, completion: nil)
            }) ~ self.disposeBag
        
        self.tableView.rx.itemSelected.asObservable()
            .`do`(onNext: { self.tableView.deselectRow(at: $0, animated: true) })
            .map { ReportPostViewModel.Action.itemSelected($0) }
            ~> self.viewModel.didActionSubject
            ~ self.disposeBag
    }
    
    func setUpContentChangedObservers() {
        self.viewModel.cells.asObservable()
            .bind(to: self.tableView.rx.items) { tableView, index, item in
                let indexPath = IndexPath(row: index, section: 0)
                switch item {
                case is TextCellViewModel:
                    let cell: TextTableViewCell = tableView.dequeueReusableCell(forIndexPath: indexPath)
                    cell.cellModel = item as? TextCellViewModel
                    return cell
                default:
                    return .init()
                }
            }.disposed(by: self.disposeBag)
    }
    
    func setUpViewToPresentObservers() {
        self.viewModel.shouldPresent.asObservable()
            .subscribe(onNext: { [weak self] viewToPresent in
                switch viewToPresent {
                case .confirmDialogController(let viewModel, let dismissable):
                    let confirmDialogViewController = ConfirmDialogViewController(viewModel)
                    let bottomSheet = BottomSheetViewController(contentViewController: confirmDialogViewController)
                    bottomSheet.dismissOnBackgroundTap = dismissable
                    self?.present(bottomSheet, animated: true, completion: nil)
                case .enterIssueViewController(let viewModel):
                    let enterIssueViewController = EnterIssueViewController()
                    enterIssueViewController.viewModel = viewModel
                    self?.navigationController?.pushViewController(enterIssueViewController, animated: true)
                case .loading(let loading):
                    loading ? self?.showLoading("Loading...") : self?.dismissLoading()
                case .dismiss:
                    self?.dismiss(animated: true, completion: nil)
                }
            }) ~ self.disposeBag
    }
}
