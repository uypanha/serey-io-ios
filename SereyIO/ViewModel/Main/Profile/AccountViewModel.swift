//
//  AccountViewModel.swift
//  SereyIO
//
//  Created by Phanha Uy on 2/14/20.
//  Copyright © 2020 Phanha Uy. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift
import RxBinding
import RxDataSources

class AccountViewModel: BasePostViewModel, ShouldPresent {
    
    enum ViewToPresent {
        case postDetailViewController
    }
    
    // output:
    lazy var shouldPresentSubject = PublishSubject<ViewToPresent>()
    
    init(_ userId: String) {
        super.init(.byUser, userId)
        
        setUpRxObservers()
    }
    
    override func prepareEmptyViewModel() -> EmptyOrErrorViewModel {
        let title = "No Post Yet!"
        let emptyMessage = "Your post will be shown here after you\nmade a post."
        return EmptyOrErrorViewModel(withErrorEmptyModel: EmptyOrErrorModel(withEmptyTitle: title, emptyDescription: emptyMessage, iconImage: R.image.emptyPost()))
    }
}

// MARK: - Preparations & Tools
extension AccountViewModel {
}

// MARK: - SetUp RxObservers
fileprivate extension AccountViewModel {
    
    func setUpRxObservers() {
        setUpContentChangedObservers()
    }
    
    func setUpContentChangedObservers() {
    }
}
