//
//  MediaPreviewViewController+LoadViews.swift
//  SereyIO
//
//  Created by Panha Uy on 22/8/22.
//  Copyright © 2022 Serey IO. All rights reserved.
//

import UIKit
import Then
import SnapKit
import RxCocoa
import MaterialComponents

extension MediaPreviewViewController {
    
    func prepareViews() -> UIView {
        let mainView = UIView()
        
        mainView.addSubview(self.containerView)
        self.containerView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        self.pageControl = .init()
        mainView.addSubview(self.pageControl)
        self.pageControl.snp.makeConstraints { make in
            make.height.equalTo(39)
            make.width.greaterThanOrEqualTo(100)
            make.centerX.equalToSuperview()
            make.bottom.equalTo(mainView.safeAreaLayoutGuide.snp.bottom).inset(16)
        }
        
        mainView.backgroundColor = .white
        return mainView
    }
    
    func setUpViews() {
        self.preparePageViewController()
        
        self.view.backgroundColor = .black
        self.containerView.backgroundColor = .clear
        self.pageViewController.view.backgroundColor = .black
        self.pageControl.backgroundColor = .clear
        
        setUpPageControl()
        self.pageViewController.delegate = self
        self.pageViewController.dataSource = self
        self.pageControl.numberOfPages = self.totalCount
        self.currentIndex = self.viewModel.currentIndex
    }
    
    private func preparePageViewController() {
        self.pageViewController = .init(transitionStyle: .scroll, navigationOrientation: .horizontal)
        self.addChild(self.pageViewController)
        self.pageViewController.view.translatesAutoresizingMaskIntoConstraints = false
        
        self.containerView.addSubview(self.pageViewController.view)
        self.pageViewController.view.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        self.pageViewController.didMove(toParent: self)
    }
    
    func setUpPageControl() {
        self.pageControl.backgroundColor = .clear
        self.pageControl.pageIndicatorTintColor = UIColor(hexString: "#CECECE")
        self.pageControl.currentPageIndicatorTintColor = ColorName.primary.color
        self.pageControl.hidesForSinglePage = true
    }
}
