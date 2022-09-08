//
//  ImageTextCellViewModel.swift
//  SereyIO
//
//  Created by Phanha Uy on 9/21/19.
//  Copyright © 2020 Serey IO. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift

class ImageTextCellViewModel: CellViewModel {
    
    let image: BehaviorSubject<UIImage?>
    let imageUrl: BehaviorSubject<String?>
    let titleText: BehaviorSubject<String?>
    let attributedText: BehaviorSubject<NSAttributedString?>
    let subTitle: BehaviorSubject<String?>
    let showSeperatorLine: BehaviorSubject<Bool>
    let backgroundColor: BehaviorSubject<UIColor?>
    
    init(model: ImageTextModel, _ indicatorAccessory: Bool = false, _ selectionType: UITableViewCell.SelectionStyle = .default, showSeperatorLine: Bool = false) {
        self.image = .init(value: model.image)
        self.imageUrl = .init(value: model.imageUrl)
        self.titleText = .init(value: nil)
        self.attributedText = .init(value: nil)
        self.subTitle = .init(value: model.subTitle)
        self.showSeperatorLine = .init(value: showSeperatorLine)
        self.backgroundColor = .init(value: .clear)
        super.init(indicatorAccessory, selectionType)
        
        if model.isHtml {
            self.attributedText.onNext(model.titleText?.htmlAttributed(size: 12))
        } else {
            self.titleText.onNext(model.titleText)
        }
    }
}
