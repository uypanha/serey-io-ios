//
//  PostDetailCellViewModel.swift
//  SereyIO
//
//  Created by Panha Uy on 4/7/20.
//  Copyright © 2020 Phanha Uy. All rights reserved.
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
}
