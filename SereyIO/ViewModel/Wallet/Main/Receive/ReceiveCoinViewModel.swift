//
//  ReceiveCoinViewModel.swift
//  SereyIO
//
//  Created by Panha Uy on 8/8/20.
//  Copyright © 2020 Phanha Uy. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift
import RxBinding

class ReceiveCoinViewModel: BaseViewModel {
    
    let username: BehaviorRelay<String?>
    let qrImage: BehaviorSubject<UIImage?>
    
    init(_ username: String) {
        self.username = .init(value: username)
        self.qrImage = .init(value: nil)
        super.init()
        
        prepareQRImage(username)
    }
}

// MARK: - Preparations & Tools
extension ReceiveCoinViewModel {
    
    func prepareQRImage(_ username: String) {
        let encryptedUsername = CryptLib().encryptPlainTextRandomIV(withPlainText: username, key: AES.AES_KEY)
        DispatchQueue.main.async {
            self.qrImage.onNext(UtilitiesHelper.generateQRCode(from: encryptedUsername ?? ""))
        }
    }
}
