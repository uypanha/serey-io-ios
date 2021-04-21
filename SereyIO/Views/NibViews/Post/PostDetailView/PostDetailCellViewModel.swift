//
//  PostDetailCellViewModel.swift
//  SereyIO
//
//  Created by Panha Uy on 4/7/20.
//  Copyright © 2020 Serey IO. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift
import RxBinding

class PostDetailCellViewModel: PostCellViewModel, CollectionSingleSecitionProviderModel {
    
    let cells: BehaviorRelay<[CellViewModel]>
    
    override init(_ discussion: PostModel?) {
        self.cells = BehaviorRelay(value: [])
        super.init(discussion)
    }
    
    required convenience init(_ isShimmering: Bool) {
        self.init(nil)
        
        self.isShimmering.accept(isShimmering)
    }
    
    override func notifyDataChanged(_ data: PostModel?) {
        super.notifyDataChanged(data)
        
        self.cells.accept(self.prepareCells(data?.categoryItem ?? []))
    }
}

// MARK: - Preparations & Tools
extension PostDetailCellViewModel {
    
    private func prepareCells(_ tags: [String]) -> [CellViewModel] {
        return tags.map { DiscussionCategoryModel(name: $0, sub: nil) }
            .map { CategoryCellViewModel($0, title: $0.name, isSelected: false, indicatorAccessory: true) }
    }
}
