//
//  ImageCellViewModel.swift
//  SereyIO
//
//  Created by Panha Uy on 5/7/22.
//  Copyright © 2022 Serey IO. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift
import RxBinding

class ImageCellViewModel: CellViewModel {
    
    let imageUrl: BehaviorRelay<URL?>
    let plusImage: BehaviorRelay<Int>
    
    init(_ imageUrl: String) {
        self.imageUrl = .init(value: URL(string: imageUrl))
        self.plusImage = .init(value: 0)
        super.init()
    }
}
