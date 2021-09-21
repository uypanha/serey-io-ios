//
//  ProfileViewModel.swift
//  Emergency
//
//  Created by Phanha Uy on 5/14/19.
//  Copyright © 2020 Serey IO. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift

class ProfileViewModel: BaseViewModel {
    
    let imageURL: BehaviorRelay<URL?>
    let shortcutLabel: BehaviorRelay<String?>
    let uniqueColor: BehaviorRelay<UIColor?>
    
    override init() {
        self.imageURL = BehaviorRelay(value: nil)
        self.shortcutLabel = BehaviorRelay(value: nil)
        self.uniqueColor = BehaviorRelay(value: nil)
        super.init()
    }
    
    convenience init(shortcut: String, imageUrl: URL?, uniqueColor: UIColor? = nil) {
        self.init()
        self.shortcutLabel.accept(shortcut.uppercased())
        self.imageURL.accept(imageUrl)
        if imageUrl == nil {
            let color = uniqueColor ?? UIColor(hexString: PFColorHash().hex(shortcut))
            self.uniqueColor.accept(color)//.onNext(DynamicColor(cgColor: color.cgColor).desaturated())
        } else {
            self.uniqueColor.accept(UIColor.white)
        }
    }
    
//    convenience init(with people: PeopleModel, imageUrl: URL?) {
//        self.init(shortcut: people.first == nil ? nil : people.first!, imageUrl: imageUrl, uniqueColor: model.uniqueColor)
//    }
//
}
