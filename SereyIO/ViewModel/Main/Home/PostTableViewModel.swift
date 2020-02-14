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

class PostTableViewModel: BasePostViewModel {
    
    let postTabType: BehaviorRelay<PostTabType>
    
    init(_ tabType: PostTabType) {
        self.postTabType = BehaviorRelay(value: tabType)
        super.init()
    }
}
