//
//  PayQRViewModel.swift
//  SereyIO
//
//  Created by Panha Uy on 8/9/20.
//  Copyright © 2020 Phanha Uy. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift
import RxBinding

class PayQRViewModel: BaseViewModel, ShouldPresent, ShouldReactToAction {
    
    enum Action {
        case qrFound(String)
        case viewMyQRPressed
    }
    
    enum ViewToPresent {
        case receiveQRCodeController
    }
    
    // input:
    let didActionSubject: PublishSubject<Action>
    
    // output:
    let shouldPresentSubject: PublishSubject<ViewToPresent>
    
    override init() {
        self.didActionSubject = .init()
        self.shouldPresentSubject = .init()
        super.init()
    }
}
