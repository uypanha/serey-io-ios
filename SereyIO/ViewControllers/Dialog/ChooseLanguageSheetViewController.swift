//
//  ChooseLanguageSheetViewController.swift
//  SereyIO
//
//  Created by Phanha Uy on 1/30/20.
//  Copyright © 2020 Phanha Uy. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift
import RxBinding
import RxDataSources

class ChooseLanguageSheetViewController: BaseViewController {
    
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var selectLanguageLabel: UILabel!
    @IBOutlet weak var tableView: ContentSizedTableView!
    
    lazy var dataSource: RxTableViewSectionedReloadDataSource<SectionItem> = { [unowned self] in
        return self.prepreDataSource()
    }()
    
    var viewModel: ChooseLanguageViewModel!
    
    var backgroundGesture: UITapGestureRecognizer? {
        didSet {
            guard let guesture = self.backgroundGesture else { return }
            
            guesture.cancelsTouchesInView = false
            view.addGestureRecognizer(guesture)
            guesture.rx.event.asObservable()
                .subscribe(onNext: { [weak self] _ in
                    self?.dismiss(animated: true, completion: nil)
                }).disposed(by: self.disposeBag)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpViews()
        setUpRxObservers()
    }
    
    override func setUpLocalizedTexts() {
        super.setUpLocalizedTexts()
        
        self.selectLanguageLabel.text = R.string.onBoard.selectLanguage.localized()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        containerView.roundCorners(corners: [.topLeft, .topRight], radius: 8)
    }
}

// MARK: - Preparations & Tools
fileprivate extension ChooseLanguageSheetViewController {
    
    func setUpViews() {
        self.backgroundGesture = UITapGestureRecognizer()
        prepareTableView()
    }
    
    func prepareTableView() {
        self.tableView.addBorders(edges: [.top], color: .lightGray)
        self.tableView.tableFooterView = UIView()
        self.tableView.separatorStyle = .none
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
fileprivate extension ChooseLanguageSheetViewController {
    
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
                    self?.dismiss(animated: true, completion: nil)
                }
            }).disposed(by: self.disposeBag)
    }
}

