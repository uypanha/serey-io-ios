//
//  MediaPreviewViewController.swift
//  SereyIO
//
//  Created by Panha Uy on 22/8/22.
//  Copyright © 2022 Serey IO. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift
import RxBinding
import MaterialComponents

class MediaPreviewViewController: BaseViewController {
    
    lazy var containerView: UIView = {
        return .init()
    }()
    
    var pageControl: MDCPageControl!
    var pageViewController: UIPageViewController!
    
    var currentIndex = 0 {
        didSet {
            self.pageControl.currentPage = self.currentIndex
        }
    }
    var totalCount = 0 {
        didSet {
            self.pageControl.numberOfPages = self.totalCount
        }
    }
    var nextIndex: Int?
    
    var viewModel: MediaPreviewViewModel!
    
    init(_ viewModel: MediaPreviewViewModel) {
        super.init(nibName: nil, bundle: nil)
        
        self.viewModel = viewModel
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        self.view = self.prepareViews()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setUpViews()
        setUpRxObservers()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.view.backgroundColor = .black
        self.navigationController?.setNavigationBarColor(UIColor.black.withAlphaComponent(0.4), tintColor: .white, isTransparent: true)
    }
}

// MARK: - Preparations & Tools
extension MediaPreviewViewController {
    
    func prepareViewController(for index: Int) -> UIViewController? {
        if let itemViewModel = self.viewModel.item(at: .init(row: index, section: 0)) {
            if itemViewModel is ImagePreviewViewModel {
                let imagePrevewViewController = ImagePrevewViewController()
                imagePrevewViewController.viewModel = itemViewModel as? ImagePreviewViewModel
                imagePrevewViewController.index = index
                return imagePrevewViewController
            } else {
                return UIViewController()
            }
        }
        
        return nil
    }
}

// MARK: - UIPageViewControllerDataSource, UIPageViewControllerDelegate
extension MediaPreviewViewController: UIPageViewControllerDataSource, UIPageViewControllerDelegate {
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        if (currentIndex == 0) { return nil }
        
        return self.prepareViewController(for: currentIndex - 1)
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        
        if currentIndex == (self.totalCount - 1) {
            return nil
        }
        
        return self.prepareViewController(for: currentIndex + 1)
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, willTransitionTo pendingViewControllers: [UIViewController]) {
        
        guard let nextVC = pendingViewControllers.first as? PageItemControllerProtocol else {
            return
        }
        
        self.nextIndex = nextVC.index
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        
        if (completed && self.nextIndex != nil) {
            self.currentIndex = self.nextIndex!
        }
        
        self.nextIndex = nil
    }
}

// MARK: - SetUp RxObservers
extension MediaPreviewViewController {
    
    func setUpRxObservers() {
        setUpControlObservers()
        setUpContentChangedObservers()
        setUpViewToPresentObservres()
    }
    
    func setUpControlObservers() {
    }
    
    func setUpContentChangedObservers() {
        self.viewModel.cells.asObservable()
            .subscribe(onNext: { [unowned self] cells in
                self.totalCount = cells.count
                self.currentIndex = self.viewModel.currentIndex
                if let viewController = self.prepareViewController(for: self.currentIndex) {
                    self.pageViewController.setViewControllers([viewController], direction: .forward, animated: true, completion: nil)
                }
            }) ~ self.disposeBag
    }
    
    func setUpViewToPresentObservres() {
//        self.viewModel.shouldPresent.asObservable()
//            .subscribe(onNext: { [unowned self] viewToPresent in
//                switch viewToPresent {
//                case .mainViewController:
//                    AppDelegate.shared?.rootViewController?.switchToMainScreent()
//                case .moveToNextPage:
//                    if let viewController = self.prepareViewController(for: self.currentIndex + 1) {
//                        self.pageViewController.setViewControllers([viewController], direction: .forward, animated: true, completion: nil)
//                        self.currentIndex += 1
//                    }
//                }
//            }) ~ self.disposeBag
    }
}
