//
//  OnBoardingViewController.swift
//  SereyIO
//
//  Created by Panha Uy on 7/8/21.
//  Copyright © 2021 Serey IO. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift
import RxBinding
import MaterialComponents

class OnBoardingViewController: BaseViewController {
    
    @IBOutlet weak var cotainerView: UIView!
    @IBOutlet weak var pageControl: MDCPageControl!
    @IBOutlet weak var nextButton: UIButton!
    
    var skipButton: UIBarButtonItem!
    var pageViewController: UIPageViewController {
        return self.children[0] as! UIPageViewController
    }
    
    var currentIndex = 0 {
        didSet {
            self.updateCurrentPage()
        }
    }
    var totalCount = 0 {
        didSet {
            self.pageControl.numberOfPages = self.totalCount
        }
    }
    var nextIndex: Int?
    
    var viewModel: OnBoardingViewModel!

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.removeNavigationBarBorder()
        self.setNeedsStatusBarAppearanceUpdate()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        setUpViews()
        setUpRxObservers()
    }
}

// MARK: - Preparations & Tools
extension OnBoardingViewController {
    
    func setUpViews() {
        setUpPageControl()
        setUpNavigationItem()
        self.nextButton.secondaryStyle()
        
        self.pageViewController.delegate = self
        self.pageViewController.dataSource = self
        self.pageControl.numberOfPages = self.totalCount
    }
    
    func setUpNavigationItem() {
        self.skipButton = .init(title: "Skip", style: .plain, target: nil, action: nil)
        self.navigationItem.rightBarButtonItem = self.skipButton
    }
    
    func setUpPageControl() {
        self.pageControl.backgroundColor = .clear
        self.pageControl.pageIndicatorTintColor = UIColor(hexString: "#CECECE")
        self.pageControl.currentPageIndicatorTintColor = .color(.primary)
        self.pageControl.hidesForSinglePage = true
    }
    
    func updateCurrentPage() {
        self.pageControl.currentPage = self.currentIndex
        if self.currentIndex == self.totalCount - 1 {
            self.navigationItem.rightBarButtonItem = nil
            self.nextButton.setTitle("Start", for: .normal)
            self.nextButton.primaryStyle()
        } else if self.nextButton.title(for: .normal) != "Next" {
            self.navigationItem.rightBarButtonItem = self.skipButton
            self.nextButton.setTitle("Next", for: .normal)
            self.nextButton.secondaryStyle()
        }
    }
    
    func prepareViewController(for index: Int) -> UIViewController? {
        if let itemViewModel = self.viewModel.item(at: .init(row: index, section: 0)) {
            if itemViewModel is ChooseCountryViewModel {
                let chooseCountryViewController = R.storyboard.onBoard.chooseCountryViewController()
                chooseCountryViewController?.viewModel = itemViewModel as? ChooseCountryViewModel
                chooseCountryViewController?.index = index
                return chooseCountryViewController
            } else if itemViewModel is FeatureViewModel {
                let featureViewController = R.storyboard.onBoard.featureViewController()
                featureViewController?.viewModel = itemViewModel as? FeatureViewModel
                featureViewController?.index = index
                return featureViewController
            } else {
                return UIViewController()
            }
        }
        
        return nil
    }
}

// MARK: - UIPageViewControllerDataSource, UIPageViewControllerDelegate
extension OnBoardingViewController: UIPageViewControllerDataSource, UIPageViewControllerDelegate {
    
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
            self.viewModel.didAction(with: .onPageLeft(self.currentIndex))
            self.currentIndex = self.nextIndex!
        }
        
        self.nextIndex = nil
    }
}

// MARK: - SetUp RxObservers
extension OnBoardingViewController {
    
    func setUpRxObservers() {
        setUpControlObservers()
        setUpContentChangedObservers()
        setUpViewToPresentObservres()
    }
    
    func setUpControlObservers() {
        self.nextButton.rx.tap.asObservable()
            .map { OnBoardingViewModel.Action.nextPressed(self.currentIndex) }
            ~> self.viewModel.didActionSubject
            ~ self.disposeBag
        
        self.skipButton.rx.tap.asObservable()
            .map { OnBoardingViewModel.Action.skipPressed }
            ~> self.viewModel.didActionSubject
            ~ self.disposeBag
    }
    
    func setUpContentChangedObservers() {
        self.viewModel.cells.asObservable()
            .subscribe(onNext: { [unowned self] cells in
                self.totalCount = cells.count
                if let viewController = self.prepareViewController(for: self.currentIndex) {
                    self.pageViewController.setViewControllers([viewController], direction: .forward, animated: true, completion: nil)
                }
                self.updateCurrentPage()
            }) ~ self.disposeBag
    }
    
    func setUpViewToPresentObservres() {
        self.viewModel.shouldPresent.asObservable()
            .subscribe(onNext: { [unowned self] viewToPresent in
                switch viewToPresent {
                case .mainViewController:
                    AppDelegate.shared?.rootViewController?.switchToMainScreen()
                case .moveToNextPage:
                    if let viewController = self.prepareViewController(for: self.currentIndex + 1) {
                        self.pageViewController.setViewControllers([viewController], direction: .forward, animated: true, completion: nil)
                        self.currentIndex += 1
                    }
                }
            }) ~ self.disposeBag
    }
}
