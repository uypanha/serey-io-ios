//
//  DraftSavedCellViewModel.swift
//  SereyIO
//
//  Created by Panha Uy on 12/24/20.
//  Copyright © 2020 Serey IO. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift
import RxBinding
import RealmSwift
import RxRealm

class DraftSavedCellViewModel: CellViewModel {
    
    let draftCount: BehaviorSubject<String?>
    
    init(_ draftCount: BehaviorSubject<String?>) {
        self.draftCount = draftCount
        super.init()
    }
}

