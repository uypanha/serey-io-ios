//
//  CellViewModel.swift
//  iOSTemplate
//
//  Created by Phanha Uy on 1/11/20.
//  Copyright © 2020 Phanha Uy. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift
import RxDataSources

class CellViewModel: BaseViewModel, IdentifiableType {
    
    let selectionType: BehaviorSubject<UITableViewCell.SelectionStyle>
    
    var identity: String {
        return self.identityData()
    }
    
    init(_ selectType: UITableViewCell.SelectionStyle = .default) {
        self.selectionType = BehaviorSubject(value: selectType)
        super.init()
    }
    
    open func identityData() -> String {
        return ""
    }
    
    override open func isEqual(_ object: Any?) -> Bool {
        if let data = object as? CellViewModel {
            return data.identity == self.identity
        }
        
        return false
    }
    
    static func == (lhs: CellViewModel, rhs: CellViewModel) -> Bool {
        return lhs.identity == rhs.identity
    }
}
