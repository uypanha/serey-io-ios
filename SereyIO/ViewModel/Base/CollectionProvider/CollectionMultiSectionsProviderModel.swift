//
//  CollectionMultiSectionsProviderModel.swift
//  SereyIO
//
//  Created by Phanha Uy on 1/11/20.
//  Copyright © 2020 Phanha Uy. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift

protocol CollectionMultiSectionsProviderModel: CollectionDataProviderModel where T: CellViewModel {
    
    var cells: BehaviorRelay<[SectionItem]> { get }
    
    func sectionTitle(in section: Int) -> String?
    
    func sectionFooter(in section: Int) -> String?
    
    func isLastSection(section: Int) -> Bool
}

extension CollectionMultiSectionsProviderModel where Self: BaseViewModel {
    
    func isEmpty() -> Bool {
        return cells.value.isEmpty
    }
    
    func numberOfSections() -> Int {
        return cells.value.count
    }
    
    func numberOfItems(in section: Int) -> Int {
        return cells.value[section].items.count
    }
    
    func item(at indexPath: IndexPath) -> CellViewModel? {
        return cells.value[indexPath.section].items[indexPath.row]
    }
    
    func isLastItem(indexPath: IndexPath) -> Bool {
        return (indexPath.section == self.numberOfSections() - 1) && (indexPath.row == self.numberOfItems(in: indexPath.section) - 1)
    }
    
    func sectionTitle(in section: Int) -> String? {
        if section < cells.value.count {
            return cells.value[section].model.header
        }
        return nil
    }
    
    func sectionFooter(in section: Int) -> String? {
        if section < cells.value.count {
            return cells.value[section].model.footer
        }
        return nil
    }
    
    func isLastSection(section: Int) -> Bool {
        return (cells.value.count - 1) == section
    }
}
