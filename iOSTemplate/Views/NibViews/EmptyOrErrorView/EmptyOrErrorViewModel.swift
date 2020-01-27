//
//  EmptyOrErrorViewModel.swift
//  KongBeiClient
//
//  Created by Phanha Uy on 6/5/19.
//  Copyright © 2019 Phanha Uy. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

class EmptyOrErrorViewModel: BaseViewModel {
    
    lazy var titleText = BehaviorSubject<String?>(value: nil)
    lazy var descriptionText = BehaviorSubject<String?>(value: nil)
    lazy var actionButtonText = BehaviorSubject<String?>(value: nil)
    lazy var iconImage = BehaviorSubject<UIImage?>(value: nil)
    lazy var topOffset = BehaviorSubject<CGFloat?>(value: nil)
    lazy var imageWidthOffset = BehaviorSubject<CGFloat?>(value: nil)
    lazy var shouldShowActionButton = BehaviorSubject<Bool>(value: true)
    lazy var actionButtonPressed = PublishSubject<Void>()
    
    init(withErrorEmptyModel model: EmptyOrErrorModel) {
        super.init()
        
        self.titleText.onNext(model.title)
        self.descriptionText.onNext(model.description)
        self.actionButtonText.onNext(model.actionTitle)
        self.iconImage.onNext(model.iconImage)
        self.topOffset.onNext(model.topOffset)
        self.imageWidthOffset.onNext(model.imageWidthOffset)
        
        self.actionButtonPressed.subscribe(onNext: { _ in
            model.completion?()
        }).disposed(by: self.disposeBag)
        
        if  model.completion == nil {
            self.shouldShowActionButton.onNext(false)
        }
    }
}

class EmptyOrErrorModel {
    
    var title: String? = nil
    var description: String? = nil
    var actionTitle: String? = nil
    var iconImage: UIImage? = nil
    var topOffset: CGFloat = 0
    var imageWidthOffset: CGFloat = 0.8
    var completion: (() -> Void)? = nil
    
    init(withEmptyTitle title: String?, emptyDescription description: String, topOffset: CGFloat? = nil, imageWidthOffset: CGFloat? = nil, iconImage: UIImage? = UIImage(), actionTitle: String? = nil, actionCompletion: (() -> Void)? = nil) {
        
        self.title = title
        self.description = description
        self.actionTitle = actionTitle
        self.topOffset = topOffset ?? 0
        self.imageWidthOffset = imageWidthOffset ?? 0.8
        self.iconImage = iconImage
        self.completion = actionCompletion
    }
    
    convenience init(withErrorInfo errorInfo: ErrorInfo, topOffset: CGFloat? = nil, imageWidthOffset: CGFloat? = nil, actionTitle: String? = nil, actionCompletion: (() -> Void)? = nil) {
        self.init(withEmptyTitle: errorInfo.errorTitle, emptyDescription: errorInfo.error.localizedDescription, topOffset: topOffset, imageWidthOffset: imageWidthOffset, iconImage: errorInfo.errorIcon, actionTitle: actionTitle, actionCompletion: actionCompletion)
    }
}
