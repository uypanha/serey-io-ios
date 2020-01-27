//
//  BaseCellViewModel.swift
//  iOSTemplate
//
//  Created by Phanha Uy on 1/11/20.
//  Copyright © 2020 Phanha Uy. All rights reserved.
//

import Foundation
import RxDataSources

typealias AnimatedSectionModel = AnimatableSectionModel<BaseCellViewModel.Section, CellViewModel>
typealias SectionItem = SectionModel<BaseCellViewModel.Section, CellViewModel>

class BaseCellViewModel: BaseViewModel {
    
    struct Section {
        var header: String?
        var footer: String?
        
        init(header: String? = nil, footer: String? = nil) {
            self.header = header
            self.footer = footer
        }
    }
}

// MARK: - Section
extension BaseCellViewModel.Section: IdentifiableType, Equatable {
    typealias Identity = String
    
    var identity: String {
        return (header ?? "") + (footer ?? "")
    }
    
    static func == (lhs: BaseCellViewModel.Section, rhs: BaseCellViewModel.Section) -> Bool {
        return lhs.identity == rhs.identity
    }
}

// MARK: - AnimatedSectionModel
extension AnimatedSectionModel {
    
    init(items: [CellViewModel]) {
        self.init(model: BaseCellViewModel.Section(), items: items)
    }
}

// MARK: - SectionItem
extension SectionItem {
    
    init(items: [CellViewModel]) {
        self.init(model: BaseCellViewModel.Section(), items: items)
    }
}
