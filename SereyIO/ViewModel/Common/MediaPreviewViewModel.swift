//
//  MediaPreviewViewModel.swift
//  SereyIO
//
//  Created by Panha Uy on 22/8/22.
//  Copyright © 2022 Serey IO. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift
import RxBinding

class MediaPreviewViewModel: BaseViewModel, CollectionSingleSecitionProviderModel {
    
    let imageUrls: BehaviorRelay<[String]>
    let cells: BehaviorRelay<[CellViewModel]>
    
    var currentIndex: Int
    
    init(_ urls: [String], currentIndex: Int) {
        self.imageUrls = .init(value: urls)
        self.cells = .init(value: [])
        self.currentIndex = currentIndex
        super.init()
        
        self.cells.accept(self.prepareCells(urls))
    }
}

// MARK: - Preparations & Tools
extension MediaPreviewViewModel {
    
    func prepareCells(_ urls: [String]) -> [CellViewModel] {
        return urls.map { ImagePreviewViewModel($0) }
    }
}
