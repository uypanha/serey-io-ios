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
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var sryTitleLabel: UILabel!
    @IBOutlet weak var sryAddressLabel: UILabel!
    @IBOutlet weak var qrImageView: UIImageView!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var shareButton: UIButton!
    @IBOutlet weak var copyButton: UIButton!
    
    private var viewGesture: UITapGestureRecognizer? {
        didSet {
            guard let gesture = self.viewGesture else { return }
            
            self.view.isUserInteractionEnabled = true
            self.view.addGestureRecognizer(gesture)
        }
    }
    
    var viewModel: ReceiveCoinViewModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setUpViews()
        setUpRxObservers()
    }
    
    override func setUpLocalizedTexts() {
        super.setUpLocalizedTexts()
        
        self.sryTitleLabel.text = "Your SRY Username"
        self.messageLabel.text = "Use this username to transfer coins from another wallet to this wallet."
    }
}

// MARK: - Preparations & Tools
extension ReceiveCoinViewController {
    
    func setUpViews() {
        self.view.backgroundColor = .clear
        self.qrImageView.isUserInteractionEnabled = true
        self.viewGesture = UITapGestureRecognizer()
        
        self.closeButton.setRadius(all: 18)
        self.copyButton.primaryStyle()
        self.shareButton.primaryStyle()
    }
}

// MARK: - SetUP RxObservers
extension ReceiveCoinViewController {
    
    func setUpRxObservers() {
        setUpContentChangedObservers()
        setUpControlObservers()
    }
    
    func setUpContentChangedObservers() {
        self.disposeBag ~ [
            self.viewModel.qrImage ~> self.qrImageView.rx.image,
            self.viewModel.username ~> self.sryAddressLabel.rx.text
        ]
    }
    
    func setUpControlObservers() {
        self.closeButton.rx.tap.asObservable()
            .subscribe(onNext: { [weak self] _ in
                self?.dismiss(animated: true, completion: nil)
            }) ~ self.disposeBag
        
        self.viewGesture?.rx.event.asObservable()
            .subscribe(onNext: { [weak self] _ in
                self?.dismiss(animated: true, completion: nil)
            }).disposed(by: self.disposeBag)
    }
}
