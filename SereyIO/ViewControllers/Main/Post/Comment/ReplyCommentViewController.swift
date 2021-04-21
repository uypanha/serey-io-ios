//
//  ReplyCommentViewController.swift
//  SereyIO
//
//  Created by Panha Uy on 4/14/20.
//  Copyright © 2020 Serey IO. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift
import RxBinding
import RxDataSources
import RxKeyboard

class ReplyCommentViewController: BaseViewController, KeyboardController, LoadingIndicatorController, VoteDialogProtocol, AlertDialogController {
    
    fileprivate lazy var keyboardDisposeBag = DisposeBag()
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var commentTextView: CommentTextView!
    @IBOutlet weak var commentContainerView: UIView!
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    
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
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.keyboardDisposeBag = DisposeBag()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        setUpKeyboardObservers()
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
        self.title = R.string.post.replies.localized()
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
        setUpShouldPresentObservers()
        setUpShouldPresentErrorObsevers()
        setUpTabSelfToDismissKeyboard(true, cancelsTouchesInView: true)?.disposed(by: self.disposeBag)
    }
    
    func setUpContentChangedObsesrvers() {
        self.commentTextView.viewModel = self.viewModel.commentViewModel
        
        self.viewModel.endRefresh.asObservable()
            .subscribe(onNext: { [weak self] endRefreshing in
                if endRefreshing {
                    self?.tableView.refreshControl?.endRefreshing()
                }
            }) ~ self.disposeBag
    }
    
    func setUpTableViewObservers() {
        self.viewModel.cells.asObservable()
            ~> self.tableView.rx.items(dataSource: self.dataSource)
            ~ self.disposeBag
        
        // Item Selected
//        self.tableView.rx.itemSelected.asObservable()
//            .bind(to: viewModel.itemSelected)
//            ~ self.disposeBag
        
        self.tableView.refreshControl?.rx.controlEvent(.valueChanged)
            .filter { return self.tableView.refreshControl!.isRefreshing }
            .map { ReplyCommentTableViewModel.Action.refresh }
            .bind(to: self.viewModel.didActionSubject)
            .disposed(by: self.disposeBag)
    }
    
    func setUpShouldPresentObservers() {
        self.viewModel.shouldPresent.asObservable()
            .subscribe(onNext: { viewToPresent in
                switch viewToPresent {
                case .loading(let loading):
                    loading ? self.showLoading() : self.dismissLoading()
                case .signInViewController:
                    if let signInViewController = R.storyboard.auth.signInViewController() {
                        signInViewController.viewModel = SignInViewModel()
                        self.show(CloseableNavigationController(rootViewController: signInViewController), sender: nil)
                    }
                case .voteDialogController(let voteDialogViewModel):
                    self.showVoteDialog(voteDialogViewModel)
                case .downVoteDialogController(let downvoteDialogViewModel):
                    self.showDownvoteDialog(downvoteDialogViewModel)
                }
            }) ~ self.disposeBag
    }
    
    func setUpShouldPresentErrorObsevers() {
        self.viewModel.shouldPresentError.asObservable()
            .subscribe(onNext: { [unowned self] errorInfo in
                self.showDialogError(errorInfo, positiveButton: R.string.common.confirm.localized(), positiveCompletion: nil)
            }).disposed(by: self.disposeBag)
    }
    
    func setUpKeyboardObservers() {
        RxKeyboard.instance.visibleHeight
            .drive(onNext: { [weak self] keyboardHeight in
                if let _self = self {
                    _self.bottomConstraint.constant = keyboardHeight
                    UIView.animate(withDuration: 0.3, animations: {
                        _self.view.layoutIfNeeded()
                    })
                }
            }).disposed(by: self.keyboardDisposeBag)
    }
}
