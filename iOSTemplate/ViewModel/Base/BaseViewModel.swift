//
//  BaseViewModel.swift
//  iOSTemplate
//
//  Created by Phanha Uy on 9/15/19.
//  Copyright © 2019 Phanha Uy. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift

// MARK: - ShouldPresentError
public protocol ShouldPresentError {
    var shouldPresentError: Driver<ErrorInfo> { get }
}

// MARK: - ShouldPresent
public protocol ShouldPresent {
    associatedtype ViewToPresent
    var shouldPresentSubject: PublishSubject<ViewToPresent> { get set }
}

extension ShouldPresent where Self: BaseViewModel {
    
    var shouldPresent: Observable<ViewToPresent> {
        get { return self.shouldPresentSubject.asObservable() }
    }
    
    func shouldPresent(_ viewToPresent: ViewToPresent) {
        self.shouldPresentSubject.onNext(viewToPresent)
    }
}

// MARK: - ShouldReactToAction
public protocol ShouldReactToAction {
    associatedtype Action
    var didActionSubject: PublishSubject<Action> { get }
}

extension ShouldReactToAction {
    
    func didAction(with action: Action) {
        self.didActionSubject.onNext(action)
    }
}

// MARK: - BaseViewModel
class BaseViewModel: NSObject, ShouldPresentError {
    
    lazy var disposeBag = DisposeBag()
    
    lazy var shouldPresentError: Driver<ErrorInfo> = {
        return shouldPresentErrorSubject.asDriverWithDefaultError()
    }()
    internal lazy var shouldPresentErrorSubject = PublishSubject<ErrorInfo>()
    
    override init() {
        super.init()
    }
    
    func shouldPresentError(_ error: ErrorInfo) {
        self.shouldPresentErrorSubject.onNext(error)
    }
}
