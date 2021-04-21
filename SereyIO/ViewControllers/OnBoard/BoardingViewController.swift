//
//  BoardingViewController.swift
//  SereyIO
//
//  Created by Phanha Uy on 1/27/20.
//  Copyright © 2020 Serey IO. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift
import RxBinding
import MaterialComponents

class BoardingViewController: BaseViewController {

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var pageControl: MDCPageControl!
    @IBOutlet weak var nextButton: UIButton!
    
    lazy var skipButton: UIBarButtonItem = { [unowned self] in
        return UIBarButtonItem(title: R.string.common.skip.localized(), style: .plain, target: nil, action: nil)
    }()
    
    var slideViews: [UIView] = [] {
        didSet {
            self.pageControl.numberOfPages = self.slideViews.count
            self.pageControl.currentPage = 0
            self.addSlidesToScrollView()
        }
    }
    
    var viewModel: BoardingViewModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setUpViews()
        setUpRxObservers()
    }
    
    override func setUpLocalizedTexts() {
        super.setUpLocalizedTexts()
        
        self.nextButton.setTitle(R.string.common.next.localized(), for: .normal)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        setupSlideScrollView(slides: self.slideViews)
    }
}

// MARK: - Preparations & Tools
fileprivate extension BoardingViewController {
    
    func setUpViews() {
        self.navigationItem.rightBarButtonItem = self.skipButton
        self.pageControl.numberOfPages = 0
        self.pageControl.pageIndicatorTintColor = .lightGray
        self.pageControl.currentPageIndicatorTintColor = .black
        self.pageControl.hidesForSinglePage = true
        
        self.nextButton.primaryStyle()
        self.nextButton.makeMeCircular()
        self.scrollView.delegate = self
    }
    
    func addSlidesToScrollView() {
        self.scrollView.removeViews()
        self.slideViews.forEach { view in
            scrollView.addSubview(view)
        }
    }
    
    func setupSlideScrollView(slides : [UIView]) {
        let contentWidth = self.scrollView.frame.width
        let contentHeight = self.scrollView.frame.height
        scrollView.contentSize = CGSize(width: contentWidth * CGFloat(slides.count), height: contentHeight)
        scrollView.isPagingEnabled = true
        
        for i in 0 ..< slides.count {
            slides[i].frame = CGRect(x: contentWidth * CGFloat(i), y: 0, width: contentWidth, height: contentHeight)
            slides[i].layoutIfNeeded()
        }
    }
    
    func createSlides(_ cells: [CellViewModel]) -> [UIView] {
        var featureViews: [UIView] = []
        cells.forEach { cell in
            if let cell = cell as? BoardFeatureViewModel {
                featureViews.append(BoardFeatureView().then {
                    $0.viewModel = cell
                })
            }
        }
        return featureViews
    }
}

// MARK: - UIScrollViewDelegate
extension BoardingViewController: UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        pageControl.scrollViewDidScroll(scrollView)
        let pageIndex = round(scrollView.contentOffset.x / self.scrollView.frame.width)
        if self.pageControl.currentPage != Int(pageIndex) {
            if Int(pageIndex) == (self.slideViews.count - 1) {
                self.nextButton.setTitle(R.string.onBoard.getStarted.localized(), for: .normal)
                self.navigationItem.rightBarButtonItem = nil
            } else {
                self.nextButton.setTitle(R.string.common.next.localized(), for: .normal)
                self.navigationItem.rightBarButtonItem = self.skipButton
            }
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        pageControl.scrollViewDidEndDecelerating(scrollView)
    }

    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        pageControl.scrollViewDidEndScrollingAnimation(scrollView)
    }
}

// MARK: - SetUp Rx Observers
fileprivate extension BoardingViewController {
    
    func setUpRxObservers() {
        setUpContentChangedObservers()
        setUpControlsObservers()
        setUpShouldPresentObservers()
    }
    
    func setUpContentChangedObservers() {
        self.viewModel.slideCellModels.asObservable()
            .subscribe(onNext: { [unowned self] cells in
                self.slideViews = self.createSlides(cells)
            }) ~ self.disposeBag
    }
    
    func setUpControlsObservers() {
        self.nextButton.rx.tap.asObservable()
            .subscribe(onNext: { [unowned self] _ in
                if self.pageControl.currentPage < (self.slideViews.count - 1) {
                    let view = self.slideViews[self.pageControl.currentPage + 1]
                    self.scrollView.scrollRectToVisible(view.frame, animated: true)
                    self.pageControl.setCurrentPage(self.pageControl.currentPage + 1, animated: true)
                } else {
                    self.viewModel.didAction(with: .beginButtonPressed)
                }
            }) ~ self.disposeBag
        
        self.skipButton.rx.tap.asObservable()
            .map { BoardingViewModel.Action.skipPressed }
            ~> self.viewModel.didActionSubject
            ~ self.disposeBag
    }
    
    func setUpShouldPresentObservers() {
        self.viewModel.shouldPresent.asObservable()
            .subscribe(onNext: { viewToPresent in
                switch viewToPresent {
                case .homeViewController:
                    AppDelegate.shared?.rootViewController?.switchToMainScreen(fadeAnimation: true)
                }
            }) ~ self.disposeBag
    }
}
