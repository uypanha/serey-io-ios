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
    let subTitle: BehaviorSubject<String?>
    let showSeperatorLine: BehaviorSubject<Bool>
    
    init(model: ImageTextModel, _ indicatorAccessory: Bool = false, _ selectionType: UITableViewCell.SelectionStyle = .default, showSeperatorLine: Bool = false) {
        self.image = .init(value: model.image)
        self.imageUrl = .init(value: model.imageUrl)
        self.titleText = .init(value: model.titleText)
        self.subTitle = .init(value: model.subTitle)
        self.showSeperatorLine = .init(value: showSeperatorLine)
        super.init(indicatorAccessory, selectionType)
    }
}
