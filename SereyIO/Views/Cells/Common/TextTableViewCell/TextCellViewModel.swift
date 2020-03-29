//
//  TextCellViewModel.swift
//  SereyIO
//
//  Created by Panha Uy on 3/25/20.
//  Copyright © 2020 Phanha Uy. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift

class TextCellViewModel: CellViewModel {
    
    let titleLabelText: BehaviorSubject<String?>
    let labelProperties: BehaviorSubject<TextLabelProperties>
    let isSelectionEnabled: BehaviorSubject<Bool>
    
    init(with text: String, properties: TextLabelProperties, indicatorAccessory: Bool, isSelectionEnabled: Bool = true) {
        self.titleLabelText = BehaviorSubject<String?>(value: nil)
        self.labelProperties =  BehaviorSubject<TextLabelProperties>(value:  TextLabelProperties.defaultProperties())
        self.isSelectionEnabled = BehaviorSubject(value: isSelectionEnabled)
        super.init(indicatorAccessory)
        
        self.titleLabelText.onNext(text)
        self.labelProperties.onNext(properties)
    }
}

struct TextLabelProperties {
    
    var font: UIFont? = nil
    var textColor: UIColor? = nil
    var backgroundColor: UIColor? = nil
    var textAlignment: NSTextAlignment? = nil
    var leadingTrailingConstant: CGFloat = 16
    
    init(font: UIFont? = nil, textColor: UIColor? = nil, backgroundColor: UIColor? = nil, alignment: NSTextAlignment? = nil, leadingTrailingConstant: CGFloat = 16) {
        self.font = font
        self.textColor = textColor
        self.backgroundColor = backgroundColor
        self.textAlignment = alignment
        self.leadingTrailingConstant = leadingTrailingConstant
    }
    
    static func defaultProperties() -> TextLabelProperties {
        return TextLabelProperties()
    }
}
