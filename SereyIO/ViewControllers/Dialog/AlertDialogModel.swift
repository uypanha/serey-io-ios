//
//  AlertDialogModel.swift
//  SereyIO
//
//  Created by Panha Uy on 8/5/20.
//  Copyright © 2020 Phanha Uy. All rights reserved.
//

import UIKit

class AlertDialogModel {
    
    let title: String?
    let message: String?
    var actions: [ActionModel]
    
    init(title: String? = nil, message: String? = nil, actions: [ActionModel] = []) {
        self.title = title
        self.message = message
        self.actions = actions
    }
}

// MARK: - Model
class ActionModel {
    
    var title: String = ""
    var actionStyle: UIAlertAction.Style = .default
    var completion: (() -> Void)
    
    init(_ title: String, style: UIAlertAction.Style = .default, completion: @escaping (() -> Void) = {}) {
        self.title = title
        self.actionStyle = style
        self.completion = completion
    }
}
