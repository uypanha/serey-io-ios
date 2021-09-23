//
//  ChooseCountryOption.swift
//  SereyIO
//
//  Created by Panha Uy on 7/14/21.
//  Copyright © 2021 Serey IO. All rights reserved.
//

import UIKit

enum ChooseCountryOption: CaseIterable {
    
    case detectAutomatically
    case global
    case chooseCountry
    
    var icon: UIImage? {
        switch self {
        case .detectAutomatically:
            return R.image.searchCountryIcon()
        case .global:
            return R.image.globalIcon()
        case .chooseCountry:
            return R.image.flagsIcon()
        }
    }
    
    var title: String {
        switch self {
        case .detectAutomatically:
            return "Detect your counry automatically"
        case .chooseCountry:
            return "Choose from country list"
        case .global:
            return "Global"
        }
    }
    
    var cellModel: ChooseCountryOptionCellViewModel {
        return ChooseCountryOptionCellViewModel(self)
    }
}

class ChooseCountryOptionCellViewModel: ImageTextCellViewModel {
    
    let option: ChooseCountryOption
    
    init(_ option: ChooseCountryOption) {
        self.option = option
        super.init(model: .init(image: option.icon, titleText: option.title))
    }
}
