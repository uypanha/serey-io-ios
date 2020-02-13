//
//  PostTableViewModel.swift
//  SereyIO
//
//  Created by Phanha Uy on 2/6/20.
//  Copyright © 2020 Phanha Uy. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift
import RxDataSources

class PostTableViewModel: BaseCellViewModel, CollectionMultiSectionsProviderModel {
    
    let postTabType: BehaviorRelay<PostTabType>
    let cells: BehaviorRelay<[SectionItem]>
    
    init(_ tabType: PostTabType) {
        self.postTabType = BehaviorRelay(value: tabType)
        self.cells = BehaviorRelay(value: [])
        super.init()
        
        self.cells.accept(self.prepareCells())
    }
}

// MARK: - Preparations & Tools
extension PostTableViewModel {
    
    fileprivate func prepareCells() -> [SectionItem] {
        let cells = (0...10).map { _ in PostCellViewModel() }
        return [SectionItem(items: cells)]
    }
}
