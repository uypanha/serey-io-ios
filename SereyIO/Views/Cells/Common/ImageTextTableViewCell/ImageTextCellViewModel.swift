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
    let titleText: BehaviorSubject<String?>
    let subTitle: BehaviorSubject<String?>
    let showSeperatorLine: BehaviorSubject<Bool>
    
    init(model: ImageTextModel, _ indicatorAccessory: Bool = false, _ selectionType: UITableViewCell.SelectionStyle = .default, showSeperatorLine: Bool = false) {
        self.image = BehaviorSubject(value: model.image)
        self.titleText = BehaviorSubject(value: model.titleText)
        self.subTitle = BehaviorSubject(value: model.subTitle)
        self.showSeperatorLine = BehaviorSubject(value: showSeperatorLine)
        super.init(indicatorAccessory, selectionType)
    }
}
