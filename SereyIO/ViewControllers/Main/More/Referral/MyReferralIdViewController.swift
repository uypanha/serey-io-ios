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
        return .createLabel(13, weight: .semibold, textColor: .color(.primary))
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
    
    lazy var inviteButton: UIButton = {
        return .createButton(with: 15, weight: .bold).then {
            $0.primaryStyle()
        }
    }()
    
    init() {
        super.init(nibName: nil, bundle: nil)
        
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
        self.referralLinkLabel.text = "https://kyc.serey.io/?referralId=YDYG43D"
    }
    
    override func setUpLocalizedTexts() {
        super.setUpLocalizedTexts()
        
        self.title = "Invite & Receive Reward"
        self.inviteButton.setTitle("Invite Friends", for: .normal)
        self.titleLabel.text = "Invite other people and receive reward."
        self.messageLabel.text = "Invite friends and other people you know to Serey by sharing them this referral link and earn free Serey Coins. You can also share them the referral link by clicking on \"Invite Friends\"."
    }
}
