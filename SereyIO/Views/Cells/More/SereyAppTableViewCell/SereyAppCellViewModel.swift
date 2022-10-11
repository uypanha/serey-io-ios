//
//  SereyAppCellViewModel.swift
//  SereyIO
//
//  Created by Panha Uy on 4/29/20.
//  Copyright © 2020 Serey IO. All rights reserved.
//

import Foundation

class SereyAppCellViewModel: ImageTextCellViewModel {
    
    let appType: SereyApp
    
    init(_ app: SereyApp) {
        self.appType = app
        super.init(model: app.imageTextModel, app.indicatorAccessory)
    }
}
