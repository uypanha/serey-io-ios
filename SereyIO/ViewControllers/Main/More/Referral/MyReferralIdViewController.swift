//
//  MyReferralIdViewController.swift
//  SereyIO
//
//  Created by Mäd on 22/03/2022.
//  Copyright © 2022 Serey IO. All rights reserved.
//

import UIKit
import Then
import SnapKit
import RxCocoa
import RxSwift
import RxBinding
import MaterialComponents

class MyReferralIdViewController: BaseViewController {
    
    lazy var titleLabel: UILabel = {
        return .createLabel(22, weight: .bold, textColor: .color(.title)).then {
            $0.numberOfLines = 0
        }
    }()
    
    lazy var messageLabel: UILabel = {
        return .createLabel(15, weight: .regular, textColor: .color(.subTitle)).then {
            $0.numberOfLines = 0
        }
    }()
    
    lazy var referralLinkLabel: UILabel = {
        return .createLabel(13, weight: .semibold, textColor: .color(.primary)).then {
            $0.lineBreakMode = .byTruncatingMiddle
        }
    }()
    
    var loadingIndicator: UIActivityIndicatorView!
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
    
    lazy var inviteButton: UIButton = {
        return .createButton(with: 15, weight: .bold).then {
            $0.primaryStyle()
        }
    }()
    
    var viewModel: MyReferralIdViewModel!
    
    init() {
        super.init(nibName: nil, bundle: nil)
        
        self.viewModel = .init()
        self.hidesBottomBarWhenPushed = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        self.view = self.prepareViews()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.viewModel.downloadData()
        setUpRxObservers()
    }
    
    override func setUpLocalizedTexts() {
        super.setUpLocalizedTexts()
        
        self.title = "Invite & Receive Reward"
        self.inviteButton.setTitle("Invite Friends", for: .normal)
        self.titleLabel.text = "Invite other people and receive reward."
        self.messageLabel.text = "Invite friends and other people you know to Serey by sharing them this referral link and earn free Serey Coins. You can also share them the referral link by clicking on \"Invite Friends\"."
    }
}

// MARK: - SetUp RxObservers
fileprivate extension MyReferralIdViewController {
    
    func setUpRxObservers() {
        setUpControlObservers()
        setUpContentChangedObservers()
        setUpViewToPresentObservers()
    }
    
    func setUpControlObservers() {
        self.copyLinkButton.rx.tap.asObservable()
            .map { MyReferralIdViewModel.Action.copyLinkPressed }
            ~> self.viewModel.didActionSubject
            ~ self.disposeBag
        
        self.inviteButton.rx.tap.asObservable()
            .map { MyReferralIdViewModel.Action.invitePressed }
            ~> self.viewModel.didActionSubject
            ~ self.disposeBag
    }
    
    func setUpContentChangedObservers() {
        self.viewModel.referralUrl.asObservable()
            .subscribe(onNext: { [weak self] link in
                self?.referralLinkLabel.text = link
                self?.copyLinkButton.isHidden = link == nil
                self?.loadingIndicator.isHidden = link != nil
                self?.inviteButton.isEnabled = link != nil
                if link == nil {
                    self?.loadingIndicator.startAnimating()
                }
            }) ~ self.disposeBag
    }
    
    func setUpViewToPresentObservers() {
        self.viewModel.shouldPresent.asObservable()
            .subscribe(onNext: { [weak self] viewToPresent in
                switch viewToPresent {
                case .showSnackBar(let messageText):
                    let message = MDCSnackbarMessage()
                    message.text = messageText
                    MDCSnackbarManager.default.show(message)
                case .inviteFriendDialogController(let viewModel):
                    let inviteFriendViewController = InviteFriendDialogViewController()
                    inviteFriendViewController.viewModel = viewModel
                    let bottomSheetController = BottomSheetViewController(contentViewController: inviteFriendViewController)
                    self?.present(bottomSheetController, animated: true, completion: nil)
                case .shareLink(let url):
                    DispatchQueue.main.async {
                        let messaage = "Join me in Serey"
                        let activityVC = UIActivityViewController(activityItems: [messaage, url], applicationActivities: nil)
                        activityVC.excludedActivityTypes = [.airDrop, .addToReadingList]
                        self?.present(activityVC, animated: true, completion: nil)
                    }
                }
            }) ~ self.disposeBag
    }
}
