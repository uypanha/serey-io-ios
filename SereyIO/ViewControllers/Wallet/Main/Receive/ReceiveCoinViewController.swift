//
//  ReceiveCoinViewController.swift
//  SereyIO
//
//  Created by Panha Uy on 8/8/20.
//  Copyright © 2020 Phanha Uy. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift
import RxBinding

class ReceiveCoinViewController: BaseViewController {
    
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var sryTitleLabel: UILabel!
    @IBOutlet weak var sryAddressLabel: UILabel!
    @IBOutlet weak var qrImageView: UIImageView!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var shareButton: UIButton!
    @IBOutlet weak var copyButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setUpViews()
        setUpRxObservers()
    }
}

// MARK: - Preparations & Tools
extension ReceiveCoinViewController {
    
    func setUpViews() {
        self.view.backgroundColor = .clear
        self.closeButton.setRadius(all: 18)
        self.copyButton.primaryStyle()
        self.shareButton.primaryStyle()
    }
}

// MARK: - SetUP RxObservers
extension ReceiveCoinViewController {
    
    func setUpRxObservers() {
        setUpControlObservers()
    }
    
    func setUpControlObservers() {
        self.closeButton.rx.tap.asObservable()
            .subscribe(onNext: { [weak self] _ in
                self?.dismiss(animated: true, completion: nil)
            }) ~ self.disposeBag
    }
}
