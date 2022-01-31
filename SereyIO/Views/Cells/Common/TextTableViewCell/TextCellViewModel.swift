//
//  TextCellViewModel.swift
//  SereyIO
//
//  Created by Panha Uy on 3/25/20.
//  Copyright © 2020 Serey IO. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift

class TextCellViewModel: CellViewModel, ShimmeringProtocol {
    
    let titleLabelText: BehaviorSubject<String?>
    let labelProperties: BehaviorSubject<TextLabelProperties>
    let isSelectionEnabled: BehaviorSubject<Bool>
    let isShimmering: BehaviorRelay<Bool>
    
    init(with text: String, properties: TextLabelProperties, indicatorAccessory: Bool, isSelectionEnabled: Bool = true) {
        self.titleLabelText = .init(value: nil)
        self.labelProperties =  .init(value: .defaultProperties())
        self.isSelectionEnabled = .init(value: isSelectionEnabled)
        self.isShimmering = .init(value: false)
        super.init(indicatorAccessory)
        
        self.titleLabelText.onNext(text)
        self.labelProperties.onNext(properties)
    }
    
    convenience required init(_ isShimmering: Bool) {
        self.init(with: "", properties: .defaultProperties(), indicatorAccessory: false)
        
        self.isShimmering.accept(isShimmering)
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
