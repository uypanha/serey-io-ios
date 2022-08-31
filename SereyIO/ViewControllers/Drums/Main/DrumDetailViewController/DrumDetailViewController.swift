//
//  DrumDetailViewController.swift
//  SereyIO
//
//  Created by Panha Uy on 15/7/22.
//  Copyright © 2022 Serey IO. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift
import RxBinding
import RxDataSources
import RxKeyboard
import SnapKit

class DrumDetailViewController: BaseViewController, KeyboardController, VoteDialogProtocol, AlertDialogController {
    
    lazy var keyboardDisposeBag: DisposeBag = .init()
    
    lazy var detailView: DrumDetailView = {
        return .init(frame: .init())
    }()
    
    lazy var tableView: ContentSizedTableView = {
        return .init(frame: .init(), style: .plain).then {
            $0.separatorStyle = .none
            $0.tableFooterView = .init(frame: .zero)
            $0.tableHeaderView = .init(frame: CGRect(x: 0, y: 0, width: 0, height: 1))
            if #available(iOS 15.0, *) {
                $0.sectionHeaderTopPadding = 0
            }
            
            $0.register(DrumReplyTableViewCell.self, isNib: false)
            $0.register(NoMorePostTableViewCell.self, isNib: false)
        }
    }()
    
    var commentContainerView: CardView!
    lazy var commentView: CommentTextView = {
        return .init()
    }()
    
    var bottomConstraint: LayoutConstraint!
    
    var viewModel: DrumDetailViewModel!
    
    lazy var dataSource: RxTableViewSectionedReloadDataSource<SectionItem> = { [unowned self] in
        return self.prepreDataSource()
    }()
    
    init(_ viewModel: DrumDetailViewModel) {
        super.init(nibName: nil, bundle: nil)
        
        self.viewModel = viewModel
        self.hidesBottomBarWhenPushed = true
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func loadView() {
        self.view = self.prepareViews()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.view.backgroundColor = .color("#FAFAFA")
        self.tableView.backgroundColor = .clear
        self.commentView.textView.textViewDelegate = self
        setUpRxObservers()
        self.viewModel.downloadData()
        
        if self.viewModel.shouldCommentFocus && AuthData.shared.isUserLoggedIn {
            DispatchQueue.main.async {
//                self.commentView.textView.becomeFirstResponder()
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        setUpRxKeyboardObservers()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.keyboardDisposeBag = DisposeBag()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        self.tableView.contentInset = .init(top: 0, left: 0, bottom: self.commentContainerView.frame.height + 16, right: 0)
    }
}

// MARK: - Preparations & Tools
private extension DrumDetailViewController {
    
    func prepreDataSource() -> RxTableViewSectionedReloadDataSource<SectionItem> {
        let dataSource = RxTableViewSectionedReloadDataSource<SectionItem>(configureCell: { (datasource, tableView, indexPath, item) -> UITableViewCell in
            switch item {
            case is DrumReplyCellViewModel:
                let cell: DrumReplyTableViewCell = tableView.dequeueReusableCell(forIndexPath: indexPath)
                cell.cellModel = item as? DrumReplyCellViewModel
                return cell
            case is NoMorePostCellViewModel:
                let cell: NoMorePostTableViewCell = tableView.dequeueReusableCell(forIndexPath: indexPath)
                cell.cellModel = item as? NoMorePostCellViewModel
                return cell
            default:
                return UITableViewCell()
            }
        })
        
        dataSource.titleForHeaderInSection = { datasource, section in
            return dataSource.sectionModels[section].model.header
        }
        
        return dataSource
    }
}

// MARK: - UITextViewDelegate
extension DrumDetailViewController: UITextViewDelegate {
    
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        if AuthData.shared.isUserLoggedIn {
            return true
        }
        self.viewModel.didAction(with: .didBeginToComment)
        return false
    }
}

// MARK: - SetUp RxObservers
private extension DrumDetailViewController {
    
    func setUpRxObservers() {
        setUpContentChangedObservers()
        setUpViewToPresentObservers()
        setUpShouldPresentErrorObservers()
        setUpTabSelfToDismissKeyboard()?.disposed(by: self.disposeBag)
    }
    
    func setUpContentChangedObservers() {
        self.detailView.cellModel = self.viewModel.drumDetailCellModel
        
        self.viewModel.cells.bind(to: self.tableView.rx.items(dataSource: self.dataSource)).disposed(by: self.disposeBag)
        self.commentView.viewModel = self.viewModel.commentViewModel
    }
    
    func setUpViewToPresentObservers() {
        self.viewModel.shouldPresent.asObservable()
            .subscribe(onNext: { [weak self] viewToPresent in
                switch viewToPresent {
                case .signInViewController:
                    if let signInViewController = R.storyboard.auth.signInViewController() {
                        signInViewController.viewModel = SignInViewModel()
                        self?.show(CloseableNavigationController(rootViewController: signInViewController), sender: nil)
                    }
                case .drumDetailViewController(let viewModel):
                    let drumDetailViewController = DrumDetailViewController(viewModel)
                    self?.show(drumDetailViewController, sender: nil)
                case .voteDialogController(let voteDialogViewModel):
                    self?.showVoteDialog(voteDialogViewModel)
                case .downVoteDialogController(let downVoewDialogViewModel):
                    self?.showDownvoteDialog(downVoewDialogViewModel)
                case .bottomListViewController(let bottomListViewModel):
                    let bottomMenuViewController = BottomMenuViewController(bottomListViewModel)
                    self?.present(bottomMenuViewController, animated: true, completion: nil)
                case .mediaPreviewViewController(let mediaPreviewViewModel):
                    let mediaPreviewController = MediaPreviewViewController(mediaPreviewViewModel)
                    let closableViewController = CloseableNavigationController(rootViewController: mediaPreviewController)
                    closableViewController.isDarkContentBackground = true
                    self?.present(closableViewController, animated: true, completion: nil)
                case .postDrumViewController(let viewModel):
                    let postDrumViewController = PostDrumViewController()
                    postDrumViewController.viewModel = viewModel
                    let nv = CloseableNavigationController(rootViewController: postDrumViewController)
                    self?.present(nv, animated: true)
                }
            }) ~ self.disposeBag
    }
    
    func setUpShouldPresentErrorObservers() {
        self.viewModel.shouldPresentError.asObservable()
            .subscribe(onNext: { [weak self] errorInfo in
                self?.showDialogError(errorInfo)
            }) ~ self.disposeBag
    }
    
    func setUpRxKeyboardObservers() {
        RxKeyboard.instance.visibleHeight
            .drive(onNext: { [weak self] keyboardHeight in
                if let _self = self {
                    _self.bottomConstraint.constant = -keyboardHeight
                    UIView.animate(withDuration: 0.3, animations: {
                        _self.view.layoutIfNeeded()
                    })
                }
            }).disposed(by: self.keyboardDisposeBag)
    }
}
