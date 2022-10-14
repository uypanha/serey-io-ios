//
//  UndoHiddenPostCellViewModel.swift
//  SereyIO
//
//  Created by Mäd on 07/02/2022.
//  Copyright © 2022 Serey IO. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift
import RxBinding

class UndoHiddenPostCellViewModel: CellViewModel {
    
    let post: PostModel
    let shouldUnhidePost: PublishSubject<PostModel>
    
    init(_ post: PostModel) {
        self.post = post
        self.shouldUnhidePost = .init()
        super.init()
    }
}
