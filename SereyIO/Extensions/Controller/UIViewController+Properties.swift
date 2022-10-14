//
//  UIViewController+Properties.swift
//  SereyIO
//
//  Created by Phanha Uy on 9/15/19.
//  Copyright © 2020 Serey IO. All rights reserved.
//

import UIKit

extension UIViewController {
    
    static var className: String {
        return NSStringFromClass(self).components(separatedBy: ".").last!
    }
    
    var bottomSafeAreaHeight: CGFloat {
        get {
            if #available(iOS 11.0, *) {
                let window = UIApplication.shared.keyWindow
                if let bottomPadding = window?.safeAreaInsets.bottom {
                    return bottomPadding
                }
            }
            return 0
        }
    }
    
    var topSafeAreaHeight: CGFloat {
        get {
            if #available(iOS 11.0, *) {
                let window = UIApplication.shared.keyWindow
                if let topPadding = window?.safeAreaInsets.top {
                    return topPadding
                }
            }
            return 0
        }
    }
    
    func overrideBackItem(_ title: String = "") {
        self.navigationController?.navigationBar.backIndicatorImage = R.image.leftArrowIcon()
        self.navigationController?.navigationBar.backIndicatorTransitionMaskImage = R.image.leftArrowIcon()
        if #available(iOS 14.0, *) {
            if !title.isEmpty { self.navigationItem.backButtonTitle = title }
            self.navigationItem.backButtonDisplayMode = .minimal
        } else {
            self.navigationItem.backBarButtonItem = UIBarButtonItem().then {
                $0.title = title
            }
        }
    }
    
    func showActionSheet(title: String? = nil, message: String? = nil, actionSheets: [ActionSheet], completion: @escaping ((_ index: Int, _ action: ActionSheet) -> Void)) {
        let actionSheetController = UIAlertController(title: title, message: message, preferredStyle: .actionSheet)
        
        actionSheets.forEach { (action) in
            let alerActionButton = UIAlertAction(title: action.title, style: action.actionStyle) { alertAction -> Void in
                if let index = actionSheets.index(where: { $0 === action }) {
                    completion(index, action)
                }
            }
            
            actionSheetController.addAction(alerActionButton)
        }
        
        actionSheetController.addAction(UIAlertAction(title: R.string.common.cancel.localized(), style: .cancel))
        
        self.present(actionSheetController, animated: true, completion: nil)
    }
    
    open class ActionSheet {
        
        var title: String = ""
        var actionStyle: UIAlertAction.Style = .default
        var tag: Any? = nil
        
        init(title: String, style: UIAlertAction.Style, tag: Any? = nil) {
            self.title = title
            self.actionStyle = style
            self.tag = tag
        }
    }
}
