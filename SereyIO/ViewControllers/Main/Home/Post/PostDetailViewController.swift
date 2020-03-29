//
//  PostDetailViewController.swift
//  SereyIO
//
//  Created by Phanha Uy on 3/6/20.
//  Copyright © 2020 Phanha Uy. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift
import RxBinding
import RichEditorView
import RxDataSources
import MaterialComponents

class PostDetailViewController: BaseViewController {
    
    @IBOutlet weak var postDetailView: PostDetailView!
    @IBOutlet weak var tableView: ContentSizedTableView!
    @IBOutlet weak var postCommentContainerView: UIView!
    @IBOutlet weak var postCommentView: PostCommentView!
    
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
}

// MARK: - Preparations & Tools
extension PostDetailViewController {
    
    func setUpViews() {
        self.postDetailView.addBorders(edges: [.bottom], color: ColorName.border.color, thickness: 1)
        self.postCommentContainerView.addBorders(edges: [.top], color: ColorName.border.color, thickness: 1)
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
            setUpMoreButtonObservers(moreButton)
        }
        if let sereyValueButton = self.sereyValueButton {
            buttonItems.append(sereyValueButton)
        }
        self.navigationItem.rightBarButtonItems = buttonItems
    }
}

// MARK: - SetUp RxObservers
extension PostDetailViewController {
    
    func setUpRxObservers() {
        setUpContentChangedObservers()
        setUpShouldPresentObservers()
    }
    
    func setUpMoreButtonObservers(_ button: UIBarButtonItem) {
        button.rx.tap.map { PostDetailViewModel.Action.morePressed }
            ~> self.viewModel.didActionSubject
            ~ self.disposeBag
    }
    
    func setUpContentChangedObservers() {
        self.viewModel.postViewModel ~> self.postDetailView.rx.viewModel ~ self.disposeBag
        self.viewModel.sereyValueText
            .subscribe(onNext: { [unowned self] title in
                self.sereyValueButton = self.prepareSereyValueButton(title)
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
    }
    
    func setUpShouldPresentObservers() {
        self.viewModel.shouldPresent.asObservable()
            .subscribe(onNext: { viewToPresent in
                switch viewToPresent {
                case .moreDialogController(let bottomMenuViewModel):
                    if let bottomMenuController = R.storyboard.dialog.bottomMenuViewController() {
                        bottomMenuController.viewModel = bottomMenuViewModel
                        let bottomSheet = MDCBottomSheetController(contentViewController: bottomMenuController)
                        bottomSheet.isScrimAccessibilityElement = false
                        bottomSheet.automaticallyAdjustsScrollViewInsets = false
                        bottomSheet.dismissOnDraggingDownSheet = false
                        self.present(bottomSheet, animated: true, completion: nil)
                    }
                }
            }) ~ self.disposeBag
    }
}
