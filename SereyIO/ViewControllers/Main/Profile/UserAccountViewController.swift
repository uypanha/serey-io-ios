//
//  UserAccountViewController.swift
//  SereyIO
//
//  Created by Panha Uy on 4/25/20.
//  Copyright © 2020 Serey IO. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift
import RxBinding
import MaterialComponents

class UserAccountViewController: BaseViewController, AlertDialogController, LoadingIndicatorController {
    
    @IBOutlet weak var uploadProfileButton: UIButton!
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
    @IBOutlet weak var tabBar: MDCTabBarView!
    
    @IBOutlet weak var topConstraint: NSLayoutConstraint!
    var lastContentOffset: CGFloat = 0
    
    var maxTopOffset: CGFloat = 60
    let minTopOffset: CGFloat = 0
    var previousScrollOffset: CGFloat = 0
    
    lazy var fileMediaHelper: MediaPickerHelper = .init(withPresenting: self)
    
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
        DispatchQueue.main.async {
            self.maxTopOffset = self.profileContainerView.frame.height
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        self.uploadProfileButton.makeMeCircular()
        setupSlideScrollView(slides: self.slideViews.map { $0.view })
        if self.slideViews.count > 0 && self.slideViews.count == self.tabItems.count && !self.viewModel.didScrolledToIndex {
            let item = self.tabItems[0]
            self.tabBar.setSelectedItem(item, animated: true)
            self.parentScrollView.scrollRectToVisible(self.slideViews[item.tag].view.frame, animated: false)
            self.viewModel.didScrolledToIndex = true
        }
    }
}

// MARK: - Preparations & Tools
extension UserAccountViewController {
    
    func setUpViews() {
        self.navigationController?.removeNavigationBarBorder()
        self.parentScrollView.refreshControl = UIRefreshControl()
        self.followLoadingIndicator.isHidden = true
        self.uploadProfileButton.setTitle("", for: .normal)
        prepareTabBar()
    }
    
    func prepareTabBar() {
        tabBar.tintColor = ColorName.primary.color
        tabBar.setTitleColor(.gray, for: .normal)
        tabBar.setTitleColor(ColorName.primary.color, for: .selected)
        
        tabBar.setTitleFont(UIFont.systemFont(ofSize: 14, weight: .medium), for: .selected)
        tabBar.setTitleFont(UIFont.systemFont(ofSize: 14, weight: .medium), for: .normal)
        tabBar.rippleColor = .clear
        tabBar.selectionIndicatorStrokeColor = ColorName.primary.color
        
        tabBar.selectionIndicatorTemplate = TabBarIndicator()
        tabBar.bottomDividerColor = ColorName.border.color
        tabBar.tabBarDelegate = self
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
                slides.append(PostTableViewController(style: .plain).then {
                    $0.viewModel = viewModel as? PostTableViewModel
                    $0.scrollViewDelegate = self
                })
            case is CommentsListViewModel:
                let commentReplyViewController = CommentReplyTableViewController(viewModel as! CommentsListViewModel)
                commentReplyViewController.scrollViewDelegate = self
                slides.append(commentReplyViewController)
            default:
                slides.append(UIViewController())
            }
        }
        self.slideViews = slides
    }
}

// MARK: - UIScrollViewDelegate
extension UserAccountViewController: MDCTabBarViewDelegate {
    
    func tabBarView(_ tabBarView: MDCTabBarView, didSelect item: UITabBarItem) {
        self.contentScrollView.scrollRectToVisible(self.slideViews[item.tag].view.frame, animated: true)
    }
}

// MARK: - UIScrollViewDelegate
extension UserAccountViewController: UIScrollViewDelegate {
    
    func prepareScrollingSwitchView(_ scrollView: UIScrollView) {
        let scrollDiff = (scrollView.contentOffset.y - previousScrollOffset)
        let isScrollingDown = scrollDiff > 0
        let isScrollingUp = scrollDiff < 0
        if self.canAnimateHeader(scrollView) {
            let currentOffset = abs(self.topConstraint.constant)
            var newOffset = currentOffset
            if isScrollingDown {
                newOffset = min(maxTopOffset, currentOffset + abs(scrollDiff))
            } else if isScrollingUp {
                print("isScrollingUp")
                newOffset = max(minTopOffset, currentOffset - abs(scrollDiff))
            }
            print("Current Offset ==> \(currentOffset), New Offset ==> \(newOffset), scrollDiff == \(scrollDiff)")
            if newOffset != currentOffset {
                self.topConstraint.constant = -newOffset//.update(offset: newOffset).activate()
                setScrollPosition(scrollView)
                previousScrollOffset = scrollView.contentOffset.y
            }
            
            if newOffset >= (self.maxTopOffset / 2) {
                self.title = self.viewModel.username.value
            } else {
                self.title = nil
            }
        }
    }
    
    func canAnimateHeader (_ scrollView: UIScrollView) -> Bool {
        let currentTopConstant = self.topConstraint.constant
        let scrollViewMaxHeight = scrollView.frame.height + currentTopConstant
        return scrollView.contentSize.height > scrollViewMaxHeight
    }
    
    func setScrollPosition(_ scrollView: UIScrollView) {
        scrollView.contentOffset = .zero
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        self.lastContentOffset = scrollView.contentOffset.y
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.prepareScrollingSwitchView(scrollView)
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
        
        self.uploadProfileButton.rx.tap.asObservable()
            .map { UserAccountViewModel.Action.changeProfilePressed }
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
            self.viewModel.isFollowHidden ~> self.followButton.rx.isHidden,
            self.viewModel.isUploadProfileHidden ~> self.uploadProfileButton.rx.isHidden
        ]
        
        self.viewModel.isFollowed.asObservable()
            .subscribe(onNext: { [weak self] isFollowed in
                if let isFollowed = isFollowed {
                    let titleColor = isFollowed ? UIColor.white : ColorName.primary.color
                    self?.followButton.setTitleColor(titleColor, for: .normal)
                    if isFollowed {
                        self?.followButton.setTitle(R.string.account.unfollow.localized(), for: .normal)
                        self?.followButton.primaryStyle()
                    } else {
                        self?.followButton.setTitle(R.string.account.follow.localized(), for: .normal)
                        self?.followButton.customBorderStyle(with: ColorName.primary.color, border: 1.5, isCircular: false)
                    }
                } else {
                    self?.followButton.setTitleColor(ColorName.primary.color, for: .normal)
                    self?.followButton.customBorderStyle(with: .lightGray, border: 1, isCircular: false)
                    self?.followButton.setTitle(R.string.account.followUnfollow.localized(), for: .normal)
                }
            }) ~ self.disposeBag
        
        self.viewModel.endRefresh.asObservable()
            .subscribe(onNext: { [weak self] endRefreshing in
                if endRefreshing {
                    self?.parentScrollView?.refreshControl?.endRefreshing()
                }
            }) ~ self.disposeBag
        
        self.fileMediaHelper.selectedPhotoSubject.asObservable()
            .subscribe(onNext: { [weak self] pickerModel in
                self?.viewModel.didAction(with: .photoSelected(pickerModel))
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
                case .signInController:
                    if let signInViewController = R.storyboard.auth.signInViewController() {
                        signInViewController.viewModel = SignInViewModel()
                        self.show(CloseableNavigationController(rootViewController: signInViewController), sender: nil)
                    }
                case .postsByCategoryController(let postTableViewModel):
                    let postTableViewController = CategoryPostsViewController()
                    postTableViewController.viewModel = postTableViewModel
                    postTableViewController.title = postTableViewModel.title
                    self.show(postTableViewController, sender: nil)
                case .signInViewController:
                    if let signInViewController = R.storyboard.auth.signInViewController() {
                        signInViewController.viewModel = SignInViewModel()
                        self.show(CloseableNavigationController(rootViewController: signInViewController), sender: nil)
                    }
                case .voteDialogController(let voteDialogViewModel):
                    (self.tabBarController as? MainTabBarViewController)?.showVoteDialog(voteDialogViewModel)
                case .downVoteDialogController(let downvoteDialogViewModel):
                    (self.tabBarController as? MainTabBarViewController)?.showDownvoteDialog(downvoteDialogViewModel)
                case .draftListViewController(let draftListViewModel):
                    let draftListViewController = DraftListViewController(draftListViewModel)
                    draftListViewController.hidesBottomBarWhenPushed = true
                    self.show(draftListViewController, sender: nil)
                case .choosePhotoController:
                    self.fileMediaHelper.showImagePicker()
                case .bottomListViewController(let bottomMenuListViewModel):
                    let bottomMenuViewController = BottomMenuViewController(bottomMenuListViewModel)
                    self.present(bottomMenuViewController, animated: true, completion: nil)
                case .profileGalleryController:
                    let profileGalleryViewController = ProfileGalleryViewController()
                    profileGalleryViewController.hidesBottomBarWhenPushed = true
                    profileGalleryViewController.viewModel = .init()
                    self.show(profileGalleryViewController, sender: nil)
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
                }
            }) ~ self.disposeBag
    }
}
