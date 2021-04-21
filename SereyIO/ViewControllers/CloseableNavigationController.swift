//
//  CloseableNavigationController.swift
//  SereyIO
//
//  Created by Phanha Uy on 9/15/19.
//  Copyright © 2020 Serey IO. All rights reserved.
//

import UIKit
import Rswift

class CloseableNavigationController: UINavigationController {
    
    private var closeIcon: UIImage?
    private var closeTitle: StringResource?
    
    fileprivate lazy var closeButton: UIButton = {
        return UIButton(type: .custom).then {
            $0.setImage(closeIcon, for: .normal) // Image can be downloaded from here below link
            $0.setImage(closeIcon?.image(withTintColor: ColorName.primary.color.withAlphaComponent(0.3)), for: .highlighted)
            if let closeTitle = self.closeTitle {
                $0.setTitle(" \(closeTitle.localized())", for: .normal)
            }
            $0.tintColor = ColorName.primary.color
            $0.setTitleColor($0.tintColor, for: .normal) // You can change the TitleColor
            $0.setTitleColor($0.tintColor.withAlphaComponent(0.3), for: .highlighted)
            $0.addTarget(self, action: #selector(self.backActionPressed), for: .touchUpInside)
        }
    }()
    
    lazy var backButton: UIBarButtonItem = { [unowned self] in
        if self.closeTitle != nil {
            return UIBarButtonItem(customView: self.closeButton)
        }
        
        return UIBarButtonItem(image: self.closeIcon, style: .plain, target: self, action: #selector(self.backActionPressed))
    }()
    
    init(rootViewController: UIViewController, closeIcon: UIImage? = R.image.clearIcon(), closeTitle: StringResource? = nil) {
        super.init(rootViewController: rootViewController)
        
        self.closeIcon = closeIcon
        self.closeTitle = closeTitle
        self.modalPresentationStyle = .fullScreen
        rootViewController.navigationItem.leftBarButtonItem = self.backButton
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.registerForNotifs()
        self.removeNavigationBarBorder()
    }
    
    @objc func backActionPressed() {
        self.dismiss(animated: true, completion: nil)
    }
    
    func onLanguageChanged() {
        if let closeTitle = self.closeTitle {
            self.closeButton.setTitle(" \(closeTitle.localized())", for: .normal)
        }
    }
}

// MARK: - NotificationObserver
extension CloseableNavigationController: NotificationObserver {
    
    func notificationReceived(_ notification: Notification) {
        guard let appNotif = notification.appNotification else { return }
        switch appNotif {
        case .languageChanged:
            self.onLanguageChanged()
        case .userDidLogOut:
            self.dismiss(animated: true, completion: nil)
        default:
            break
        }
    }
}

