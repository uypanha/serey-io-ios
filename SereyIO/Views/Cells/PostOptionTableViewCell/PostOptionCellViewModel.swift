//
//  PostOptionCellViewModel.swift
//  SereyIO
//
//  Created by Panha Uy on 11/5/22.
//  Copyright © 2022 Serey IO. All rights reserved.
//

import RxCocoa
import RxSwift
import RxBinding
import UIKit

class PostOptionCellViewModel: CellViewModel {
    
    let postOption: PostMenu
    let icon: BehaviorSubject<UIImage?>
    let title: BehaviorSubject<String?>
    let subTitle: BehaviorSubject<String?>
    
    init(_ postOption: PostMenu) {
        self.postOption = postOption
        self.icon = .init(value: postOption.icon)
        self.title = .init(value: postOption.title)
        self.subTitle = .init(value: postOption.subTitle)
        super.init()
    }
}
