//
//  ReceiveCoinViewModel.swift
//  SereyIO
//
//  Created by Panha Uy on 8/8/20.
//  Copyright © 2020 Phanha Uy. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift
import RxBinding

class ReceiveCoinViewModel: BaseViewModel, ShouldReactToAction, ShouldPresent {

    enum Action {
        case sharePressed
        case copyPressed
    }
    
    enum ViewToPresent {
        case shareQRImage(image: UIImage)
        case snackbar(message: String)
    }
    
    // input:
    let didActionSubject: PublishSubject<Action>
    
    // output:
    let shouldPresentSubject: PublishSubject<ViewToPresent>
    
    let username: BehaviorRelay<String?>
    let qrImage: BehaviorRelay<UIImage?>
    
    init(_ username: String) {
        self.didActionSubject = .init()
        self.shouldPresentSubject = .init()
        
        self.username = .init(value: username)
        self.qrImage = .init(value: nil)
        super.init()
        
        setUpRxObservers()
        prepareQRImage(username)
    }
}

// MARK: - Preparations & Tools
extension ReceiveCoinViewModel {
    
    func prepareQRImage(_ username: String) {
        let encryptedUsername = CryptLib().encryptPlainTextRandomIV(withPlainText: username, key: AES.AES_KEY)
        DispatchQueue.main.async {
            self.qrImage.accept(UtilitiesHelper.generateQRCode(from: encryptedUsername ?? ""))
        }
    }
}

// MARK: - Action Handlers
fileprivate extension ReceiveCoinViewModel {
    
    func handleSharePressed() {
        if let qrImage = self.qrImage.value {
            self.shouldPresent(.shareQRImage(image: qrImage))
        }
    }
}

// MARK: - SetUp RxObservers
extension ReceiveCoinViewModel {
    
    func setUpRxObservers() {
        setUpActionObservers()
    }
    
    func setUpActionObservers() {
        self.didActionSubject.asObserver()
            .subscribe(onNext: { [weak self] action in
                switch action {
                case .sharePressed:
                    self?.handleSharePressed()
                case .copyPressed:
                    UIPasteboard.general.string = self?.username.value
                    self?.shouldPresent(.snackbar(message: "Username Copied"))
                }
            }) ~ self.disposeBag
    }
}
