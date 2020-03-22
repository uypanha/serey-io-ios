//
//  AccountVIewController.swift
//  SereyIO
//
//  Created by Phanha Uy on 2/12/20.
//  Copyright © 2020 Phanha Uy. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift
import RxBinding
import RxDataSources
import NVActivityIndicatorView
import SnapKit

class AccountViewController: BaseViewController {
    
    @IBOutlet weak var profileView: ProfileView!
    @IBOutlet weak var profileNameLabel: UILabel!
    @IBOutlet weak var postCountLabel: UILabel!
    @IBOutlet weak var followersCountLabel: UILabel!
    @IBOutlet weak var followingCountLabel: UILabel!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var tableView: ContentSizedTableView!
    @IBOutlet weak var profileContainerView: UIView!
    @IBOutlet weak var followButton: UIButton!
    @IBOutlet weak var tableViewHeightConstraint: NSLayoutConstraint!
    
    fileprivate weak var emptyView: EmptyOrErrorView? = nil {
        didSet {
            self.tableView?.backgroundView = emptyView
        }
    }
    
    lazy var dataSource: RxTableViewSectionedReloadDataSource<SectionItem> = { [unowned self] in
        return self.prepreDataSource()
        }()
    
    var viewModel: AccountViewModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        setUpViews()
        setUpRxObservers()
        viewModel.downloadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.removeNavigationBarBorder()
    }
}

// MARK: - Preparations & Tools
extension AccountViewController {
    
    func setUpViews() {
        self.tableViewHeightConstraint.constant = self.scrollView.frame.height - self.profileContainerView.frame.height
        self.profileContainerView.addBorders(edges: [.bottom], color: UIColor.lightGray.withAlphaComponent(0.2))
        self.followButton.setTitleColor(ColorName.primary.color, for: .normal)
        self.followButton.customBorderStyle(with: ColorName.primary.color, border: 1.5, isCircular: false)
        
        prepareTableView()
    }
    
    func prepareTableView() {
        self.tableView.backgroundColor = ColorName.postBackground.color
        self.tableView.tableFooterView = UIView()
        self.tableView.separatorColor = ColorName.border.color
        
        self.tableView.register(PostTableViewCell.self)
    }
    
    func prepreDataSource() -> RxTableViewSectionedReloadDataSource<SectionItem> {
        let dataSource = RxTableViewSectionedReloadDataSource<SectionItem>(configureCell: { (datasource, tableView, indexPath, item) -> UITableViewCell in
            switch item {
            case is PostCellViewModel:
                let cell: PostTableViewCell = tableView.dequeueReusableCell(forIndexPath: indexPath)
                cell.cellModel = item as? PostCellViewModel
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

// MARK: - SetUp Rx Observers
fileprivate extension AccountViewController {
    
    func setUpRxObservers() {
        setUpContentChangedObservers()
        setUpTableViewObservers()
        setUpShouldPresentObservers()
    }
    
    func setUpContentChangedObservers() {
        
        self.disposeBag ~ [
            self.viewModel.profileViewModel ~> self.profileView.rx.profileViewModel,
            self.viewModel.accountName ~> self.profileNameLabel.rx.text,
            self.viewModel.postCountText ~> self.postCountLabel.rx.text,
            self.viewModel.followerCountText ~> self.followersCountLabel.rx.text,
            self.viewModel.followingCountText ~> self.followingCountLabel.rx.text,
            self.viewModel.isFollowHidden ~> self.followButton.rx.isHidden
        ]
        
        self.viewModel.cells.asObservable()
            .`do`(onNext: { [weak self] cells in
                if !cells.isEmpty {
                    self?.emptyView?.removeFromSuperview()
                    self?.emptyView = nil
                }
            }) ~> self.tableView.rx.items(dataSource: self.dataSource)
            ~ self.disposeBag
        
        self.viewModel.emptyOrError.asObservable()
            .subscribe(onNext: { [weak self] emptyOrErrorViewModel in
                if let emptyOrErrorViewModel = emptyOrErrorViewModel {
                    self?.prepareToDisplayEmptyView(emptyOrErrorViewModel)
                }
            }) ~ self.disposeBag
    }
    
    func setUpTableViewObservers() {
        // Item Selected
        self.tableView.rx.itemSelected.asObservable()
            .map { AccountViewModel.Action.itemSelected($0) }
            .bind(to: self.viewModel.didActionSubject)
            ~ self.disposeBag
        
        self.tableView.rx.willDisplayCell.asObservable()
            .subscribe(onNext: { [unowned self] (cell, indexPath) in
                if self.viewModel.isLastItem(indexPath: indexPath) {
                    self.viewModel.downloadData()
                }
            }) ~ self.disposeBag
    }
    
    func setUpShouldPresentObservers() {
        self.viewModel.shouldPresent.asObservable()
            .subscribe(onNext: { viewToPresent in
                switch viewToPresent {
                case .postDetailViewController(let postDetailViewModel):
                    if let postDetailViewController = R.storyboard.post.postDetailViewController() {
                        postDetailViewController.viewModel = postDetailViewModel
                        postDetailViewController.hidesBottomBarWhenPushed = true
                        self.show(postDetailViewController, sender: nil)
                    }
                }
            }) ~ self.disposeBag
    }
}

