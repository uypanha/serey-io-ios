//
//  UploadImageCellViewModel.swift
//  SereyIO
//
//  Created by Mäd on 28/12/2021.
//  Copyright © 2021 Serey IO. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift
import RxBinding
import UIKit

class UploadImageCellViewModel: CellViewModel {
    
    let image: BehaviorSubject<UIImage?>
    
    init(_ image: UIImage?) {
        self.image = .init(value: image)
        super.init()
    }
}
