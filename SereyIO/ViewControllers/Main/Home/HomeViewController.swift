//
//  HomeViewController.swift
//  SereyIO
//
//  Created by Phanha Uy on 2/2/20.
//  Copyright © 2020 Phanha Uy. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift
import RxBinding
import MaterialComponents

class HomeViewController: BaseViewController {
    
    @IBOutlet weak var tabBar: MDCTabBar!
    @IBOutlet weak var scrollView: UIScrollView!
    
    private lazy var logoBarItem: UIBarButtonItem = {
        let customView = UIImageView()
        customView.image = R.image.logo()
        return UIBarButtonItem(customView: customView)
    }()
    
    private lazy var filterButton: UIBarButtonItem = { [unowned self] in
        return UIBarButtonItem(image: R.image.filterIcon(), style: .plain, target: nil, action: nil)
    }()
    
    var tabItems: [UITabBarItem] = [] {
        didSet {
            tabBar.items = self.tabItems
        }
    }
    
    var slideViews: [UIViewController] = [] {
        didSet {
            addSlidesToScrollView()
        }
    }
    
    var viewModel: HomeViewModel!

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
extension HomeViewController {
    
    func setUpViews() {
        self.navigationController?.removeNavigationBarBorder()
        self.navigationItem.leftBarButtonItem = logoBarItem
        self.navigationItem.rightBarButtonItem = filterButton
        
        self.scrollView.delegate = self
        self.scrollView.backgroundColor = ColorName.postBackground.color
        
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
        self.scrollView.removeViews()
        self.slideViews.forEach { viewController in
            scrollView.addSubview(viewController.view)
        }
    }
    
    func setupSlideScrollView(slides : [UIView]) {
        let contentWidth = self.scrollView.frame.width
        let contentHeight = self.scrollView.frame.height
        scrollView.contentSize = CGSize(width: contentWidth * CGFloat(slides.count), height: contentHeight)
        scrollView.isPagingEnabled = true
        scrollView.isScrollEnabled = false
        
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
    
    fileprivate func prepareSlidingViews(_ viewModels: [PostTableViewModel]) {
        var slides: [UIViewController] = []
        viewModels.forEach { postViewModel in
            slides.append(PostTableViewController(style: .plain).then { $0.viewModel = postViewModel })
        }
        self.slideViews = slides
    }
}

// MARK: - TabBarControllerDelegate
extension HomeViewController: TabBarControllerDelegate {
    
    func configureTabBar(_ tag: Int) {
        self.tabBarItem = UITabBarItem(title: "Home", image: R.image.tabHome(), selectedImage: R.image.tabHomeSelected())
        self.tabBarItem?.tag = tag
    }
}

// MARK: - UIScrollViewDelegate
extension HomeViewController: UIScrollViewDelegate, MDCTabBarDelegate {
    
//    func scrollViewDidScroll(_ scrollView: UIScrollView) {
//        let pageIndex = round(scrollView.contentOffset.x / self.scrollView.frame.width)
//        if self.tabBar.selectedItem?.tag != Int(pageIndex) {
//            let index = Int(pageIndex)
//            self.tabBar.setSelectedItem(self.tabItems[index], animated: true)
//        }
//    }
//
    func tabBar(_ tabBar: MDCTabBar, willSelect item: UITabBarItem) {
        self.scrollView.scrollRectToVisible(self.slideViews[item.tag].view.frame, animated: true)
    }
}

// MARK: - SetUp Rx Observers
fileprivate extension HomeViewController {
    
    func setUpRxObservers() {
        setUpControlsObserver()
        setUpContentChangedObservers()
        setUpShouldPresentObservers()
    }
    
    func setUpControlsObserver() {
        self.filterButton.rx.tap.asObservable()
            .map { _ in HomeViewModel.Action.filterPressed }
            ~> self.viewModel.didActionSubject
            ~ self.disposeBag
    }
    
    func setUpContentChangedObservers() {
        self.viewModel.postTabTitles.asObservable()
            .subscribe(onNext: { [weak self] titles in
                self?.prepareTabTitles(titles)
            }) ~ self.disposeBag
        
        self.viewModel.postViewModels.asObservable()
            .subscribe(onNext: { [weak self] viewModels in
                self?.prepareSlidingViews(viewModels)
            }) ~ self.disposeBag
    }
    
    func setUpShouldPresentObservers() {
        self.viewModel.shouldPresent.asObservable()
            .subscribe(onNext: { viewToPresent in
                switch viewToPresent {
                case .choosePostCategoryController(let chooseCategorySheetViewModel):
                    if let choosePostCategoryViewController = R.storyboard.home.chooseCategorySheetViewController() {
                        choosePostCategoryViewController.viewModel = chooseCategorySheetViewModel
                        let bottomSheet = MDCBottomSheetController(contentViewController: choosePostCategoryViewController)
                        bottomSheet.isScrimAccessibilityElement = false
                        bottomSheet.automaticallyAdjustsScrollViewInsets = false
                        bottomSheet.dismissOnDraggingDownSheet = false
                        self.present(bottomSheet, animated: true, completion: nil)
                    }
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
