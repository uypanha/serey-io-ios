//
//  ChooseCountryOption.swift
//  SereyIO
//
//  Created by Panha Uy on 7/14/21.
//  Copyright © 2021 Serey IO. All rights reserved.
//

import UIKit
import RxRelay
import RxBinding

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
    
    var isSelected: Bool {
        switch self {
        case .global:
            return PreferenceStore.shared.currentCountry == nil
        default:
            return false
        }
    }
    
    var cellModel: ChooseCountryOptionCellViewModel {
        return ChooseCountryOptionCellViewModel(self, isSelected: self.isSelected)
    }
}

class ChooseCountryOptionCellViewModel: ImageTextCellViewModel {
    
    let option: ChooseCountryOption
    let isSelected: BehaviorRelay<Bool>
    
    init(_ option: ChooseCountryOption, isSelected: Bool) {
        self.option = option
        self.isSelected = .init(value: isSelected)
        super.init(model: .init(image: option.icon, titleText: option.title))
        
        self.isSelected.map { $0 ? UIColor.color(.primary).withAlphaComponent(0.15) : .clear } ~> self.backgroundColor ~ self.disposeBag
    }
}

class CountryCellViewModel: ImageTextCellViewModel {
    
    let country: CountryModel
    let isSelected: BehaviorRelay<Bool>
    
    init(_ country: CountryModel, isSelected: Bool = false) {
        self.country = country
        self.isSelected = .init(value: isSelected || (PreferenceStore.shared.currentCountry?.countryName == country.countryName))
        super.init(model: .init(imageUrl: country.iconUrl, titleText: country.countryName))
        
        self.isSelected.map { $0 ? UIColor.color(.primary).withAlphaComponent(0.15) : .clear } ~> self.backgroundColor ~ self.disposeBag
    }
}
