//
//  CollectionSingleSecitionProviderModel.swift
//  SereyIO
//
//  Created by Phanha Uy on 1/11/20.
//  Copyright © 2020 Serey IO. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift

protocol CollectionSingleSecitionProviderModel: CollectionDataProviderModel where T: CellViewModel {
    
    var cells: BehaviorRelay<[T]> { get }
}

extension CollectionSingleSecitionProviderModel where Self: BaseViewModel {
    
    func isEmpty() -> Bool {
        return cells.value.isEmpty
    }
    
    func numberOfSections() -> Int {
        return 1
    }
    
    func numberOfItems(in section: Int) -> Int {
        return cells.value.count
    }
    
    func item(at indexPath: IndexPath) -> CellViewModel? {
        if indexPath.row < cells.value.count {
            return cells.value[indexPath.row]
        }
        return nil
    }
    
    func isLastItem(indexPath: IndexPath) -> Bool {
        return indexPath.row == self.numberOfItems(in: indexPath.section) - 1
    }
}
