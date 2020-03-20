//
//  SearchViewController.swift
//  SereyIO
//
//  Created by Phanha Uy on 2/2/20.
//  Copyright © 2020 Phanha Uy. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift
import RxBinding
import RxDataSources
import SnapKit

class SearchViewController: BaseViewController {
    
    @IBOutlet weak var searchTextField: PaddingTextField!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    
    fileprivate weak var emptyView: EmptyOrErrorView? = nil {
        didSet {
            self.tableView?.backgroundView = emptyView
        }
    }
    
    lazy var dataSource: RxTableViewSectionedReloadDataSource<SectionItem> = { [unowned self] in
        return self.prepreDataSource()
    }()
    
    var viewModel: SearchViewModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        setUpViews()
        setUpRxObservers()
        viewModel.initialData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
    }
}

// MARK: - Preparations & Tools
extension SearchViewController {
    
    func setUpViews() {
        self.searchTextField.makeMeCircular()
        self.searchTextField.rightView = UIImageView(image: R.image.tabSearch()?.image(withTintColor: .black))
        self.searchTextField.rightViewMode = .always
        
        prepareTableView()
    }
    
    func prepareTableView() {
        self.tableView.tableFooterView = UIView()
        self.tableView.separatorColor = ColorName.border.color
        self.tableView.register(PeopleTableViewCell.self)
    }
    
    func prepreDataSource() -> RxTableViewSectionedReloadDataSource<SectionItem> {
        let dataSource = RxTableViewSectionedReloadDataSource<SectionItem>(configureCell: { (datasource, tableView, indexPath, item) -> UITableViewCell in
            switch item {
            case is PeopleCellViewModel:
                let cell: PeopleTableViewCell = tableView.dequeueReusableCell(forIndexPath: indexPath)
                cell.cellModel = item as? PeopleCellViewModel
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
    
    private func prepareToDisplayEmptyView(_ model: EmptyOrErrorViewModel) {
        let emptyView = EmptyOrErrorView()
        emptyView.viewModel = model
        self.emptyView = emptyView
    }
}

// MARK: - TabBarControllerDelegate
extension SearchViewController: TabBarControllerDelegate {
    
    func configureTabBar(_ tag: Int) {
        self.tabBarItem = UITabBarItem(title: "Search", image: R.image.tabSearch(), selectedImage: R.image.tabSearchSelected())
        self.tabBarItem?.tag = tag
    }
}

// MARK: - SetUp Rx Observers
fileprivate extension SearchViewController {
    
    func setUpRxObservers() {
        setUpContentChangedObservers()
        setUpShouldPresentObservers()
        setUpShouldPresentErrorObsevers()
    }
    
    func setUpContentChangedObservers() {
        
        self.viewModel.searchTextFieldViewModel.bind(with: self.searchTextField)
        
        self.viewModel.cells.asObservable()
            .`do`(onNext: { [weak self] cells in
                if !cells.isEmpty {
                    self?.emptyView?.removeFromSuperview()
                    self?.emptyView = nil
                }
            })
            .bind(to: self.tableView.rx.items(dataSource: self.dataSource))
            .disposed(by: self.disposeBag)
        
        // Item Selected
        self.tableView.rx.itemSelected.asObservable()
            .map { SearchViewModel.Action.itemSelected(at: $0) }
            .bind(to: self.viewModel.didActionSubject)
            .disposed(by: self.disposeBag)
        
        self.searchTextField.rx.controlEvent(.editingChanged)
            .map { SearchViewModel.Action.searchEditingChanged }
            .bind(to: self.viewModel.didActionSubject)
            .disposed(by: self.disposeBag)
    }
    
    func setUpShouldPresentObservers() {
        self.viewModel.shouldPresent.asObservable()
            .subscribe(onNext: { [unowned self] viewToPresent in
                switch viewToPresent {
                case .emptyResult(let emptyViewModel):
                    self.prepareToDisplayEmptyView(emptyViewModel)
                case .accountViewController(let accountViewModel):
                    if let accountViewController = R.storyboard.profile.accountViewController() {
                        accountViewController.viewModel = accountViewModel
                        self.show(accountViewController, sender: nil)
                    }
                }
            }).disposed(by: self.disposeBag)
    }
    
    func setUpShouldPresentErrorObsevers() {
        //        self.viewModel.shouldPresentError.asObservable()
        //            .subscribe(onNext: { [unowned self] errorInfo in
        //                if self.viewModel.cells.value.isEmpty {
        //                    self.prepareToDisplayEmptyView(self.viewModel.prepareEmptyViewModel(errorInfo))
        //                } else {
        //                    self.showDialogError(errorInfo, positiveButton: R.string.common.tryAgain.localized(), positiveCompletion: {
        //                        self.viewModel.downloadData()
        //                    }, negativeButton: R.string.common.cancel.localized())
        //                }
        //            }).disposed(by: self.disposeBag)
    }
}
