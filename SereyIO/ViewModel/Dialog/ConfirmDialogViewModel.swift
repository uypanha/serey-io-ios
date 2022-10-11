//
//  ConfirmDialogViewModel.swift
//  SereyIO
//
//  Created by Mäd on 03/02/2022.
//  Copyright © 2022 Serey IO. All rights reserved.
//

import UIKit

class ConfirmDialogViewModel: AlertDialogModel {
    
    let icon: UIImage?
    
    init(icon: UIImage? = nil, title: String, message: String, action: ActionModel) {
        self.icon = icon
        super.init(title: title, message: message, actions: [action])
    }
}
