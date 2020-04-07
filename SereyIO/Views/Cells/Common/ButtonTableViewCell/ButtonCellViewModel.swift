//
//  ButtonCellViewModel.swift
//  SereyIO
//
//  Created by Phanha Uy on 12/26/19.
//  Copyright © 2019 Phanha Uy. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift

class ButtonCellViewModel: CellViewModel {
    
    let titleText: BehaviorSubject<String?>
    let properties: BehaviorSubject<ButtonProperties>
    let shouldFireButtonAction: PublishSubject<Void>
    
    init(_ title: String, _ properties: ButtonProperties = ButtonProperties.defaultProperties()) {
        self.titleText = BehaviorSubject(value: title)
        self.properties = BehaviorSubject(value: properties)
        self.shouldFireButtonAction = PublishSubject()
        super.init()
    }
}

class ButtonProperties: NSObject {
    
    var font: UIFont? = nil
    var textColor: UIColor? = nil
    var backgroundColor: UIColor? = nil
    var borderColor: UIColor? = nil
    var isCircular: Bool = false
    
    init(font: UIFont? = nil, textColor: UIColor? = nil, backgroundColor: UIColor? = nil, borderColor: UIColor? = nil, isCircular: Bool = false) {
        self.font = font
        self.textColor = textColor
        self.backgroundColor = backgroundColor
        self.borderColor = borderColor
        self.isCircular = isCircular
    }
    
    static func defaultProperties() -> ButtonProperties {
        return ButtonProperties()
    }
}
