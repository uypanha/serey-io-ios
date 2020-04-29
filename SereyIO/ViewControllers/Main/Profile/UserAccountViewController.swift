//
//  UserAccountViewController.swift
//  SereyIO
//
//  Created by Panha Uy on 4/25/20.
//  Copyright © 2020 Phanha Uy. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift
import RxBinding
import MaterialComponents

class UserAccountViewController: BaseViewController, AlertDialogController, LoadingIndicatorController {
    
    @IBOutlet weak var profileView: ProfileView!
    @IBOutlet weak var profileNameLabel: UILabel!
    @IBOutlet weak var postCountLabel: UILabel!
    @IBOutlet weak var followersCountLabel: UILabel!
    @IBOutlet weak var followingCountLabel: UILabel!
    @IBOutlet weak var parentScrollView: UIScrollView!
    @IBOutlet weak var contentScrollView: UIScrollView!
    @IBOutlet weak var profileContainerView: UIView!
    @IBOutlet weak var followButton: UIButton!
    @IBOutlet weak var followLoadingIndicator: UIActivityIndicatorView!
    @IBOutlet weak var tabBar: MDCTabBar!
    
    private var tabItems: [UITabBarItem] = [] {
        didSet {
            tabBar.items = self.tabItems
        }
    }
    
    private var slideViews: [UIViewController] = [] {
        didSet {
            addSlidesToScrollView()
        }
    }
    
    var viewModel: UserAccountViewModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setUpViews()
        setUpRxObservers()
        viewModel.downloadData()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        setupSlideScrollView(slides: self.slideViews.map { $0.view })
    }
}

// MARK: - Preparations & Tools
extension UserAccountViewController {
    
    func setUpViews() {
        self.navigationController?.removeNavigationBarBorder()
        self.parentScrollView.refreshControl = UIRefreshControl()
        self.followLoadingIndicator.isHidden = true
        prepareTabBar()
    }
    
    func prepareTabBar() {
        tabBar.tintColor = ColorName.primary.color
        tabBar.setTitleColor(.gray, for: .normal)
        tabBar.setTitleColor(ColorName.primary.color, for: .selected)
        tabBar.selectedItemTitleFont = UIFont.systemFont(ofSize: 14, weight: .medium)
        tabBar.unselectedItemTitleFont = UIFont.systemFont(ofSize: 14, weight: .medium)
        tabBar.displaysUppercaseTitles = false
        tabBar.rippleColor = .clear
        tabBar.enableRippleBehavior = false
        tabBar.inkColor = .clear
        tabBar.itemAppearance = .titles
        tabBar.alignment = .justified
        tabBar.selectionIndicatorTemplate = TabBarIndicator()
        tabBar.bottomDividerColor = ColorName.border.color
        tabBar.delegate = self
    }
    
    func addSlidesToScrollView() {
        self.contentScrollView.removeViews()
        self.slideViews.forEach { viewController in
            contentScrollView.addSubview(viewController.view)
        }
    }
    
    func setupSlideScrollView(slides : [UIView]) {
        let contentWidth = self.contentScrollView.frame.width
        let contentHeight = self.contentScrollView.frame.height
        contentScrollView.contentSize = CGSize(width: contentWidth * CGFloat(slides.count), height: contentHeight)
        contentScrollView.isPagingEnabled = true
        contentScrollView.isScrollEnabled = false
        
        for i in 0 ..< slides.count {
            slides[i].frame = CGRect(x: contentWidth * CGFloat(i), y: 0, width: contentWidth, height: contentHeight)
            slides[i].layoutIfNeeded()
        }
    }
    
    fileprivate func prepareTabTitles(_ titles: [String]) {
        var items: [UITabBarItem] = []
        for i in (0...(titles.count - 1)) {
            items.append(UITabBarItem(title: titles[i], image: nil, tag: i))
        }
        self.tabItems = items
    }
    
    fileprivate func prepareSlidingViews(_ viewModels: [BaseViewModel]) {
        var slides: [UIViewController] = []
        viewModels.forEach { viewModel in
            switch viewModel {
            case is PostTableViewModel:
                slides.append(PostTableViewController(style: .plain).then { $0.viewModel = viewModel as? PostTableViewModel })
            case is CommentsListViewModel:
                let commentReplyViewController = CommentReplyTableViewController(viewModel as! CommentsListViewModel)
                slides.append(commentReplyViewController)
            default:
                slides.append(UIViewController())
            }
        }
        self.slideViews = slides
    }
}

// MARK: - UIScrollViewDelegate
extension UserAccountViewController: MDCTabBarDelegate {
    
    func tabBar(_ tabBar: MDCTabBar, willSelect item: UITabBarItem) {
        self.contentScrollView.scrollRectToVisible(self.slideViews[item.tag].view.frame, animated: true)
    }
}

// MARK: - SetUp RxObservers
extension UserAccountViewController {
    
    func setUpRxObservers() {
        setUpControlsObsservers()
        setUpContentChangedObservers()
        setUpShouldPresentObservers()
    }
    
    func setUpControlsObsservers() {
        self.parentScrollView.refreshControl?.rx.controlEvent(.valueChanged)
            .filter { return self.parentScrollView.refreshControl!.isRefreshing }
            .map { UserAccountViewModel.Action.refresh }
            .bind(to: self.viewModel.didActionSubject)
            .disposed(by: self.disposeBag)
        
        self.followButton.rx.tap.asObservable()
            .map { UserAccountViewModel.Action.followPressed }
            ~> self.viewModel.didActionSubject
            ~ self.disposeBag
    }
    
    func setUpContentChangedObservers() {
        self.viewModel.tabTitles.asObservable()
            .subscribe(onNext: { [weak self] titles in
                self?.prepareTabTitles(titles)
            }) ~ self.disposeBag
        
        self.viewModel.tabViewModels.asObservable()
            .subscribe(onNext: { [weak self] viewModels in
                self?.prepareSlidingViews(viewModels)
            }) ~ self.disposeBag
        
        self.disposeBag ~ [
            self.viewModel.profileViewModel ~> self.profileView.rx.profileViewModel,
            self.viewModel.accountName ~> self.profileNameLabel.rx.text,
            self.viewModel.postCountText ~> self.postCountLabel.rx.text,
            self.viewModel.followerCountText ~> self.followersCountLabel.rx.text,
            self.viewModel.followingCountText ~> self.followingCountLabel.rx.text,
            self.viewModel.isFollowHidden ~> self.followButton.rx.isHidden
        ]
        
        self.viewModel.isFollowed.asObservable()
            .subscribe(onNext: { [weak self] isFollowed in
                let titleColor = isFollowed ? UIColor.white : ColorName.primary.color
                self?.followButton.setTitleColor(titleColor, for: .normal)
                if isFollowed {
                    self?.followButton.setTitle(R.string.account.unfollow.localized(), for: .normal)
                    self?.followButton.primaryStyle()
                } else {
                    self?.followButton.setTitle(R.string.account.follow.localized(), for: .normal)
                    self?.followButton.customBorderStyle(with: ColorName.primary.color, border: 1.5, isCircular: false)
                }
            }) ~ self.disposeBag
        
        self.viewModel.endRefresh.asObservable()
            .subscribe(onNext: { [weak self] endRefreshing in
                if endRefreshing {
                    self?.parentScrollView?.refreshControl?.endRefreshing()
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
                case .editPostController(let editPostViewModel):
                    if let createPostController = R.storyboard.post.createPostViewController() {
                        createPostController.viewModel = editPostViewModel
                        let createPostNavigationController = CloseableNavigationController(rootViewController: createPostController)
                        self.present(createPostNavigationController, animated: true, completion: nil)
                    }
                case .loading(let loading):
                    loading ? self.showLoading() : self.dismissLoading()
                case .followLoading(let loading):
                    self.followLoadingIndicator.isHidden = !loading
                    if loading {
                        self.followLoadingIndicator.startAnimating()
                    }
                }
            }) ~ self.disposeBag
    }
}
