//
//  InviteFriendDialogViewController.swift
//  SereyIO
//
//  Created by Panha on 1/4/22.
//  Copyright © 2022 Serey IO. All rights reserved.
//

import UIKit
import Then
import SnapKit
import RxCocoa
import RxSwift
import RxBinding

class InviteFriendDialogViewController: BaseViewController, BottomSheetProtocol {
    
    var preferredBottomSheetContentSize: CGSize? {
        let preferedSize = CGSize(width: self.view.frame.width, height: self.containerView.frame.height + 48)
        return preferedSize
    }
    
    var containerView: CardView!
    lazy var titleLabel: UILabel = {
        return .createLabel(14, weight: .semibold, textColor: .color(.title)).then {
            $0.snp.makeConstraints { make in
                make.height.equalTo(24)
            }
        }
    }()
    
    lazy var closeButton: UIButton = {
        return .init().then {
            $0.setImage(R.image.smallCloseIcon(), for: .normal)
            $0.tintColor = .color(.title)
        }
    }()
    
    lazy var referralLinkLabel: UILabel = {
        return .createLabel(13, weight: .semibold, textColor: .color("#9BAABD")).then {
            $0.lineBreakMode = .byTruncatingMiddle
        }
    }()
    
    lazy var copyLinkButton: UIButton = {
        return .createButton().then {
            $0.setImage(R.image.copyIcon(), for: .normal)
            $0.tintColor = .color(.primary)
            $0.snp.makeConstraints { make in
                make.width.height.equalTo(24)
            }
            $0.customStyle(with: .clear)
        }
    }()
    
    var viewModel: InviteFriendDialogViewModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setUpViews()
        setUpRxObservers()
    }
    
    override func setUpLocalizedTexts() {
        super.setUpLocalizedTexts()
        
        self.titleLabel.text = "Invite with"
    }
}

// MARK: - Preparations & Tools
extension InviteFriendDialogViewController {
    
    func setUpViews() {
        let mainView = self.prepareViews()
        self.view.addSubview(mainView)
        mainView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}

// MARK: - SetUp RxObservers
fileprivate extension InviteFriendDialogViewController {
    
    func setUpRxObservers() {
        setUpControlObservers()
        setUpContentChangedObservers()
    }
    
    func setUpControlObservers() {
        self.closeButton.rx.tap.asObservable()
            .subscribe(onNext: { [weak self] _ in
                self?.dismiss(animated: true, completion: nil)
            }) ~ self.disposeBag
    }
    
    func setUpContentChangedObservers() {
        self.viewModel.referralUrl ~> self.referralLinkLabel.rx.text ~ self.disposeBag
    }
}
