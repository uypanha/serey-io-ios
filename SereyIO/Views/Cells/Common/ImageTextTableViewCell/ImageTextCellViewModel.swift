//
//  ImageTextCellViewModel.swift
//  SereyIO
//
//  Created by Phanha Uy on 9/21/19.
//  Copyright © 2019 Phanha Uy. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift

class ImageTextCellViewModel: CellViewModel {
    
    let image: BehaviorSubject<UIImage?>
    let titleText: BehaviorSubject<String?>
    let subTitle: BehaviorSubject<String?>
    
    init(model: ImageTextModel, _ indicatorAccessory: Bool = false, _ selectionType: UITableViewCell.SelectionStyle = .default) {
        self.image = BehaviorSubject(value: model.image)
        self.titleText = BehaviorSubject(value: model.titleText)
        self.subTitle = BehaviorSubject(value: model.subTitle)
        super.init(indicatorAccessory, selectionType)
    }
}
