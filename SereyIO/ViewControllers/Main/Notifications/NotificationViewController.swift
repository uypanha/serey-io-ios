//
//  NotificationViewController.swift
//  SereyIO
//
//  Created by Phanha Uy on 2/2/20.
//  Copyright © 2020 Serey IO. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift
import RxDataSources
import RxBinding

class NotificationViewController: BaseTableViewController {
    
    var emptyErrorView: EmptyOrErrorView? = nil {
        didSet {
            self.tableView.backgroundView = self.emptyErrorView
        }
    }
    
    lazy var dataSource: RxTableViewSectionedReloadDataSource<SectionItem> = { [unowned self] in
        return self.prepreDataSource()
    }()
    
    var viewModel: NotificationViewModel!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setUpViews()
        setUpRxObservers()
        viewModel.downloadData()
    }
    
    override func setUpLocalizedTexts() {
        super.setUpLocalizedTexts()
        
        self.title = R.string.notifications.notifications.localized()
    }
    
    override func notificationReceived(_ notification: Notification) {
        super.notificationReceived(notification)
        
        switch notification.appNotification {
        case .userDidLogin, .userDidLogOut:
            DispatchQueue.main.async {
                self.viewModel.shouldUpdateCells()
            }
        case .languageChanged:
            DispatchQueue.main.async {
                self.viewModel.shouldPrepareCells()
            }
        default:
            break
        }
    }
}

// MARK: - TabBarControllerDelegate
extension NotificationViewController: TabBarControllerDelegate {
    
    func configureTabBar(_ tag: Int) {
        self.tabBarItem = UITabBarItem(title: R.string.notifications.notifications.localized(), image: R.image.tabNotification(), selectedImage: R.image.tabNotificationSelected())
        self.tabBarItem?.tag = tag
    }
}

// MARK: - Preparations & Tools
extension NotificationViewController {
    
    func setUpViews() {
        self.navigationController?.removeNavigationBarBorder()
        setUpTableView()
    }
    
    func setUpTableView() {
        self.refreshControl = .init()
        self.tableView.tableFooterView = .init()
        self.tableView.separatorStyle = .none
        self.tableView.register(NotificationTableCell.self, isNib: false)
    }
    
    func prepreDataSource() -> RxTableViewSectionedReloadDataSource<SectionItem> {
        let dataSource = RxTableViewSectionedReloadDataSource<SectionItem>(configureCell: { (datasource, tableView, indexPath, item) -> UITableViewCell in
            switch item {
            case is NotificationCellViewModel:
                let cell: NotificationTableCell = tableView.dequeueReusableCell(forIndexPath: indexPath)
                cell.cellModel = item as? NotificationCellViewModel
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
    
    func prepareEmptyState(_ emptyModel: EmptyOrErrorViewModel?) {
        self.tableView.backgroundView = nil
        if let emptyViewModel = emptyModel {
            self.emptyErrorView = .init().then {
                $0.viewModel = emptyViewModel
            }
        }
    }
}

// MARK: - SetUp RxObservers
extension NotificationViewController {
    
    func setUpRxObservers() {
        setUpControlObservers()
        setUpContentChangedObservers()
        setUpViewToPresentObservers()
    }
    
    func setUpControlObservers() {
        self.tableView.rx.willDisplayCell.asObservable()
            .subscribe(onNext: { [unowned self] cell, indexPath in
                if self.viewModel.isLastItem(indexPath: indexPath) {
                    self.viewModel.downloadData()
                }
            }) ~ self.disposeBag
        
        self.tableView.rx.itemSelected.asObservable()
            .`do`(onNext: { self.tableView.deselectRow(at: $0, animated: true) })
            .map { NotificationViewModel.Action.itemSelected($0) }
            ~> self.viewModel.didActionSubject
            ~ self.disposeBag
        
        self.refreshControl?.rx.controlEvent(.valueChanged)
            .filter { _ in self.refreshControl?.isRefreshing == true }
            .map { _ in NotificationViewModel.Action.refresh }
            .bind(to: self.viewModel.didActionSubject)
            .disposed(by: self.disposeBag)
    }
    
    func setUpContentChangedObservers() {
        self.viewModel.cells.asObservable()
            .bind(to: self.tableView.rx.items(dataSource: self.dataSource))
            ~ self.disposeBag
        
        self.viewModel.emptyOrErrorViewModel.asObservable()
            .subscribe(onNext: { [weak self] state in
                self?.prepareEmptyState(state)
            }) ~ self.disposeBag
        
        self.viewModel.isDownloading.asObservable()
            .subscribe(onNext: { [weak self] isDownloading in
                if !isDownloading {
                    self?.refreshControl?.endRefreshing()
                }
            }) ~ self.disposeBag
    }
    
    func setUpViewToPresentObservers() {
        self.viewModel.shouldPresent.asObservable()
            .subscribe(onNext: { [weak self] viewToPresent in
                switch viewToPresent {
                case .postDetailViewController(let postDetailViewModel):
                    if let postDetailViewController = R.storyboard.post.postDetailViewController() {
                        postDetailViewController.viewModel = postDetailViewModel
                        postDetailViewController.hidesBottomBarWhenPushed = true
                        self?.show(postDetailViewController, sender: nil)
                    }
                case .profileViewController(let userAccountViewModel):
                    if let userAccountViewController = R.storyboard.profile.userAccountViewController() {
                        userAccountViewController.viewModel = userAccountViewModel
                        self?.show(userAccountViewController, sender: nil)
                    }
                case .signInController(let signInViewModel):
                    if let signInViewController = R.storyboard.auth.signInViewController() {
                        signInViewController.viewModel = signInViewModel
                        self?.show(CloseableNavigationController(rootViewController: signInViewController), sender: nil)
                    }
                }
            }) ~ self.disposeBag
    }
}
