//
//  ImagePrevewViewController.swift
//  SereyIO
//
//  Created by Panha Uy on 22/8/22.
//  Copyright © 2022 Serey IO. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift
import RxBinding
import RxKingfisher

class ImagePrevewViewController: BaseViewController, PageItemControllerProtocol {
    
    var scrollView: ZoomingScrollView!
    var imageView: UIImageView!
    
    var viewModel: ImagePreviewViewModel!
    var index: Int = 0
    
    override func loadView() {
        self.view = self.prepareViews()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setUpViews()
        setUpRxObservers()
    }
}

// MARK: - Preparations & Tools
extension ImagePrevewViewController {
    
    func setUpViews() {
        self.scrollView.viewForZooming = self.imageView
        self.scrollView.alwaysBounceHorizontal = false
        self.scrollView.alwaysBounceVertical = false
        self.scrollView.showsVerticalScrollIndicator = false
        self.scrollView.flashScrollIndicators()
        
        self.scrollView.minimumZoomScale = 1.0
        self.scrollView.maximumZoomScale = 5
        self.imageView.clipsToBounds = false
        self.imageView.kf.indicatorType = .activity
    }
}

// MARK: - SetUp RxObservers
extension ImagePrevewViewController {
    
    func setUpRxObservers() {
        self.viewModel.imageUrl
            .map { URL(string: $0) }
            .bind(to: self.imageView.kf.rx.image())
            ~ self.disposeBag
    }
}

