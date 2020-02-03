//
//  ProfileViewModel.swift
//  Emergency
//
//  Created by Phanha Uy on 5/14/19.
//  Copyright © 2019 Phanha Uy. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift

class ProfileViewModel: BaseViewModel {
    
    let imageURL: BehaviorRelay<URL?>
    
    init(_ imageUrl: URL?) {
        self.imageURL = BehaviorRelay(value: imageUrl)
        super.init()
    }
}
