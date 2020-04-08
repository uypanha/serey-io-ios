//
//  MoreAppsViewModel.swift
//  SereyIO
//
//  Created by Panha Uy on 4/8/20.
//  Copyright © 2020 Phanha Uy. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift

class MoreAppsViewModel: BaseListTableViewModel {
    
    init() {
        super.init([], true)
    }
    
    override func downloadData() {
        super.downloadData()
    }
}

// MARK: - Preparations & Tools
extension MoreAppsViewModel {
    
    enum SereyApps {
        case marketPlace
        case sour
        case lottery
    }
}
