//
//  ImagePreviewViewModel.swift
//  SereyIO
//
//  Created by Panha Uy on 22/8/22.
//  Copyright © 2022 Serey IO. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift
import RxBinding

class ImagePreviewViewModel: CellViewModel {
    
    let imageUrl: BehaviorRelay<String>
    
    init(_ url: String) {
        self.imageUrl = .init(value: url)
        super.init()
    }
}
