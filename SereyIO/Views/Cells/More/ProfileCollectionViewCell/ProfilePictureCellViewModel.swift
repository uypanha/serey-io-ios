//
//  ProfilePictureCellViewModel.swift
//  SereyIO
//
//  Created by Mäd on 27/12/2021.
//  Copyright © 2021 Serey IO. All rights reserved.
//

import RxCocoa
import RxSwift
import RxBinding
import UIKit

class ProfilePictureCellViewModel: CellViewModel, ShimmeringProtocol {
    
    let profile: BehaviorRelay<UserProfileModel?>
    let selectedProfile: BehaviorRelay<UserProfileModel?>
    
    let profileUrl: BehaviorSubject<URL?>
    let buttonImage: BehaviorSubject<UIImage?>
    let buttonBackgroundColor: BehaviorSubject<UIColor?>
    let isSelected: BehaviorSubject<Bool>
    let isShimmering: BehaviorRelay<Bool>
    
    required convenience init(_ isShimmering: Bool) {
        self.init(nil, .init(value: nil))
        
        self.isShimmering.accept(isShimmering)
    }
    
    init(_ profile: UserProfileModel?, _ selectedProfile: BehaviorRelay<UserProfileModel?>) {
        self.profile = .init(value: profile)
        self.selectedProfile = selectedProfile
        self.profileUrl = .init(value: URL(string: profile?.imageUrl ?? ""))
        self.buttonImage = .init(value: (profile?.active == true) ? R.image.checkedCircleIcon() : R.image.removeIcon())
        self.buttonBackgroundColor = .init(value: (profile?.active == true) ? UIColor(hexString: "#2979FF") : UIColor(hexString: "#F35050").withAlphaComponent(0.58))
        self.isSelected = .init(value: false)
        self.isShimmering = .init(value: false)
        super.init()
        
        setUpRxObservers()
    }
}

// MARK: - SetUp RxObservers
extension ProfilePictureCellViewModel {
    
    func setUpRxObservers() {
        self.selectedProfile.asObservable()
            .map { $0 != nil && $0?.id == self.profile.value?.id }
            ~> self.isSelected
            ~ self.disposeBag
    }
}
