//
//  BottomMenuViewModel.swift
//  SereyIO
//
//  Created by Panha Uy on 3/26/20.
//  Copyright © 2020 Phanha Uy. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift
import RxBinding

class BottomMenuViewModel: BaseCellViewModel, CollectionSingleSecitionProviderModel, ShouldReactToAction {
    
    enum Action {
        case itemSelected(IndexPath)
    }
    
    // input:
    lazy var didActionSubject = PublishSubject<Action>()
    
    let cells: BehaviorRelay<[CellViewModel]>
    
    init(_ items: [ImageTextCellViewModel]) {
        self.cells = BehaviorRelay(value: items)
        super.init()
    }
}
