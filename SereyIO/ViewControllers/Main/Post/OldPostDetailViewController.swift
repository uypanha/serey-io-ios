//
//  OldPostDetailViewController.swift
//  SereyIO
//
//  Created by Phanha Uy on 3/6/20.
//  Copyright © 2020 Serey IO. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift
import RxBinding
import RichEditorView
import RxDataSources
import MaterialComponents
import RxKeyboard

class OldPostDetailViewController: BaseViewController, AlertDialogController, LoadingIndicatorController, VoteDialogProtocol {
    
    fileprivate lazy var keyboardDisposeBag = DisposeBag()
    fileprivate lazy var moreButtonDisposeBag = DisposeBag()
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var postDetailView: PostDetailView!
    @IBOutlet weak var tableView: ContentSizedTableView!
    @IBOutlet weak var postCommentContainerView: UIView!
    @IBOutlet weak var postCommentView: PostCommentView!
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    
    private var sereyValueButton: UIBarButtonItem?
    private var moreButton: UIBarButtonItem?
    
    lazy var dataSource: RxTableViewSectionedReloadDataSource<SectionItem> = { [unowned self] in
        return self.prepreDataSource()
    }()

    var viewModel: PostDetailViewModel!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setUpViews()
        setUpRxObservers()
        viewModel.downloadData()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        self.keyboardDisposeBag = DisposeBag()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        setUpKeyboardObservers()
    }
}

// MARK: - Preparations & Tools
extension OldPostDetailViewController {
    
    func setUpViews() {
        self.scrollView.refreshControl = UIRefreshControl()
        self.postDetailView.addBorders(edges: [.bottom], color: .color(.border), thickness: 1)
        self.postCommentContainerView.addBorders(edges: [.top], color: .color(.border), thickness: 1)
        prepareTableView()
    }
    
    func prepareTableView() {
        self.tableView.tableFooterView = UIView()
        self.tableView.separatorStyle = .none
        self.tableView.register(CommentTableViewCell.self)
    }
    
    func prepareSereyValueButton(_ title: String) -> UIBarButtonItem {
        let button = UIButton().then {
            $0.setTitle(title, for: .normal)
            $0.setImage(R.image.currencyIcon(), for: .normal)
            $0.setTitleColor(.black, for: .normal)
            $0.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .medium)
            $0.titleEdgeInsets = UIEdgeInsets(top: 0, left: 4, bottom: 0, right: -4)
        }
        return UIBarButtonItem(customView: button)
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
    
    func prepareRightButtonItems() {
        var buttonItems: [UIBarButtonItem] = []
        if let moreButton = self.moreButton {
            buttonItems.append(moreButton)
            self.moreButtonDisposeBag = DisposeBag()
            setUpMoreButtonObservers(moreButton)
        }
        if let sereyValueButton = self.sereyValueButton {
            buttonItems.append(sereyValueButton)
        }
        self.navigationItem.rightBarButtonItems = buttonItems
    }
}

// MARK: - SetUp RxObservers
extension OldPostDetailViewController {
    
    func setUpRxObservers() {
        setUpControlsObsservers()
        setUpContentChangedObservers()
        setUpShouldPresentObservers()
        setUpShouldPresentErrorObsevers()
    }
    
    func setUpControlsObsservers() {
        self.scrollView.refreshControl?.rx.controlEvent(.valueChanged)
            .filter { return self.scrollView.refreshControl!.isRefreshing }
            .map { PostDetailViewModel.Action.refresh }
            .bind(to: self.viewModel.didActionSubject)
            .disposed(by: self.disposeBag)
    }
    
    func setUpMoreButtonObservers(_ button: UIBarButtonItem) {
        button.rx.tap.map { PostDetailViewModel.Action.morePressed }
            ~> self.viewModel.didActionSubject
            ~ self.moreButtonDisposeBag
    }
    
    func setUpContentChangedObservers() {
        self.disposeBag ~ [
            self.viewModel.postViewModel ~> self.postDetailView.rx.viewModel,
            self.viewModel.commentPostViewModel ~> self.postCommentView.rx.viewModel
        ]
        
        self.viewModel.sereyValueText
            .subscribe(onNext: { [unowned self] title in
                self.sereyValueButton = Constants.showReward ? self.prepareSereyValueButton(title) : nil
                self.prepareRightButtonItems()
            }) ~ self.disposeBag
        
        self.viewModel.isMoreHidden
            .subscribe(onNext: { [unowned self] isHidden in
                self.moreButton = isHidden ? nil : UIBarButtonItem(image: R.image.moreVertIcon(), style: .plain, target: nil, action: nil)
                self.prepareRightButtonItems()
            }) ~ self.disposeBag
        
        self.viewModel.cells.asObservable()
            .bind(to: self.tableView.rx.items(dataSource: self.dataSource))
            .disposed(by: self.disposeBag)
        
        self.viewModel.endRefresh.asObservable()
            .subscribe(onNext: { [weak self] endRefreshing in
                if endRefreshing {
                    self?.scrollView.refreshControl?.endRefreshing()
                }
            }) ~ self.disposeBag
    }
    
    func setUpShouldPresentObservers() {
        self.viewModel.shouldPresent.asObservable()
            .subscribe(onNext: { viewToPresent in
                switch viewToPresent {
                case .dismiss:
                    self.navigationController?.popViewController(animated: true)
                case .moreDialogController(let bottomMenuViewModel):
                    let bottomMenuController = BottomMenuViewController(bottomMenuViewModel)
                    self.present(bottomMenuController, animated: true, completion: nil)
                case .editPostController(let editPostViewModel):
                    if let createPostController = R.storyboard.post.createPostViewController() {
                        createPostController.viewModel = editPostViewModel
                        let createPostNavigationController = CloseableNavigationController(rootViewController: createPostController)
                        self.present(createPostNavigationController, animated: true, completion: nil)
                    }
                case .deletePostDialog(let confirm):
                    self.showDialog(nil, title: R.string.post.deleteArticleQ.localized(), message: R.string.post.deleteArticleMessage.localized(), dismissable: false, positiveButton: R.string.common.delete.localized(), positiveCompletion: {
                        confirm()
                    }, negativeButton: R.string.common.no.localized())
                case .loading(let loading):
                    loading ? self.showLoading() : self.dismissLoading()
                case .signInViewController:
                    if let signInViewController = R.storyboard.auth.signInViewController() {
                        signInViewController.viewModel = SignInViewModel()
                        self.show(CloseableNavigationController(rootViewController: signInViewController), sender: nil)
                    }
                case .replyComment(let replyCommentViewModel):
                    if let replyCommentViewController = R.storyboard.post.replyCommentViewController() {
                        replyCommentViewController.viewModel = replyCommentViewModel
                        self.show(CloseableNavigationController(rootViewController: replyCommentViewController), sender: nil)
                    }
                case .voteDialogController(let voteDialogViewModel):
                    self.showVoteDialog(voteDialogViewModel)
                case .downVoteDialogController(let downvoteDialogViewModel):
                    self.showDownvoteDialog(downvoteDialogViewModel)
                case .userAccountController(let userAccountViewModel):
                    if let accountViewController = R.storyboard.profile.userAccountViewController() {
                        accountViewController.viewModel = userAccountViewModel
                        self.show(accountViewController, sender: nil)
                    }
                case .votersViewController(let voterListViewModel):
                    let votersViewController = VotersViewController(voterListViewModel)
                    let bottomSheet = BottomSheetListViewController(contentViewController: votersViewController)
                    self.present(bottomSheet, animated: true, completion: nil)
                case .reportPostController(let viewModel):
                    let reportPostViewController = ReportPostViewController()
                    reportPostViewController.viewModel = viewModel
                    self.present(UINavigationController(rootViewController: reportPostViewController).then {
                        $0.modalPresentationStyle = .fullScreen
                    }, animated: true, completion: nil)
                case .confirmViewController(let viewModel):
                    let confirmDialogViewController = ConfirmDialogViewController(viewModel)
                    let bottomSheet = BottomSheetViewController(contentViewController: confirmDialogViewController)
                    self.present(bottomSheet, animated: true, completion: nil)
                case .shareLink(let url, let message):
                    DispatchQueue.main.async {
                        let activityVC = UIActivityViewController(activityItems: [message, url], applicationActivities: nil)
                        activityVC.excludedActivityTypes = [.airDrop, .addToReadingList]
                        self.present(activityVC, animated: true, completion: nil)
                    }
                case .postsByCategoryController(let viewModel):
                    let postTableViewController = CategoryPostsViewController()
                    postTableViewController.viewModel = viewModel
                    postTableViewController.title = viewModel.title
                    self.show(postTableViewController, sender: nil)
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
