//
//  CellViewModel.swift
//  SereyIO
//
//  Created by Phanha Uy on 1/11/20.
//  Copyright © 2020 Serey IO. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift
import RxDataSources

class CellViewModel: BaseViewModel, IdentifiableType {
    
    let selectionType: BehaviorSubject<UITableViewCell.SelectionStyle>
    let indicatorAccessory: BehaviorSubject<Bool>
    
    var identity: String {
        return self.identityData()
    }
    
    init(_ indicatorAccessory: Bool = false, _ selectType: UITableViewCell.SelectionStyle = .default) {
        self.selectionType = BehaviorSubject(value: selectType)
        self.indicatorAccessory = BehaviorSubject(value: indicatorAccessory)
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
