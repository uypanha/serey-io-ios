//
//  ConfirmDialogViewModel.swift
//  SereyIO
//
//  Created by Mäd on 03/02/2022.
//  Copyright © 2022 Serey IO. All rights reserved.
//

import UIKit

class ConfirmDialogViewModel: AlertDialogModel {
    
    init(title: String, message: String, action: ActionModel) {
        super.init(title: title, message: message, actions: [action])
    }
}
