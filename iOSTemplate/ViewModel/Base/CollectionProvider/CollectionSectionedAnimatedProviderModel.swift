//
//  CollectionSectionedAnimatedProviderModel.swift
//  iOSTemplate
//
//  Created by Phanha Uy on 1/11/20.
//  Copyright © 2020 Phanha Uy. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift

protocol CollectionSectionedAnimatedProviderModel: CollectionDataProviderModel where T: CellViewModel {
    
    var cells: BehaviorRelay<[AnimatedSectionModel]> { get }
    
    func sectionHeaderTitle(in section: Int) -> String?
    
    func sectionFooterTitle(in section: Int) -> String?
}

extension CollectionSectionedAnimatedProviderModel where Self: BaseViewModel {
    
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
    
    func sectionHeaderTitle(in section: Int) -> String? {
        return cells.value[section].model.header
    }
    
    func sectionFooterTitle(in section: Int) -> String? {
        return cells.value[section].model.footer
    }
    
    func isLastSection(section: Int) -> Bool {
        return (cells.value.count - 1) == section
    }
}
