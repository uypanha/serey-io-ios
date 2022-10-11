//
//  PeopleCellViewModel.swift
//  SereyIO
//
//  Created by Phanha Uy on 3/4/20.
//  Copyright © 2020 Serey IO. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift
import RxBinding

class PeopleCellViewModel: CellViewModel, ShimmeringProtocol {
    
    let isShimmering: BehaviorRelay<Bool>
    
    let people: BehaviorRelay<PeopleModel?>
    let nameText: BehaviorSubject<String?>
    let profileModel: BehaviorSubject<ProfileViewModel?>
    
    init(_ people: PeopleModel?) {
        self.people = BehaviorRelay(value: people)
        self.nameText = BehaviorSubject(value: nil)
        self.profileModel = BehaviorSubject(value: nil)
        self.isShimmering = BehaviorRelay(value: false)
        super.init(true)
        
        self.nameText.onNext(people)
        self.profileModel.onNext(people?.profileViewModel)
    }
    
    required convenience init(_ isShimmering: Bool) {
        self.init(nil)
        
        self.indicatorAccessory.onNext(false)
        self.selectionType.onNext(.none)
        self.profileModel.onNext(nil)
        self.isShimmering.accept(isShimmering)
        
    }
}
