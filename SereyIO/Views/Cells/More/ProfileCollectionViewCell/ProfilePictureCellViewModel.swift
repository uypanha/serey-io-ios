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

class ProfilePictureCellViewModel: ImageCollectionCellViewModel {
    
    let profile: BehaviorRelay<UserProfileModel?>
    let selectedProfile: BehaviorRelay<UserProfileModel?>
    
    let isSelected: BehaviorRelay<Bool>
    
    let shouldRemoveProfile: PublishSubject<UserProfileModel>
    
    init(_ profile: UserProfileModel?, _ selectedProfile: BehaviorRelay<UserProfileModel?>) {
        self.profile = .init(value: profile)
        self.selectedProfile = selectedProfile
        self.isSelected = .init(value: false)
        
        self.shouldRemoveProfile = .init()
        super.init(.init(string: profile?.imageUrl ?? ""))
        
        setUpContentChangedObservers()
    }
    
    required convenience init(_ isShimmering: Bool) {
        self.init(nil, .init(value: nil))
        
        self.isShimmering.accept(isShimmering)
    }
    
    override func handleActionButtonPressed() {
        if let profile = self.profile.value, !profile.active {
            self.shouldRemoveProfile.onNext(profile)
        }
    }
}

// MARK: - Setup RxObservers
extension ProfilePictureCellViewModel {
    
    func setUpContentChangedObservers() {
        self.selectedProfile.asObservable()
            .map { $0 != nil && $0?.id == self.profile.value?.id }
            ~> self.isSelected
            ~ self.disposeBag
        
        self.profile.asObservable()
            .subscribe(onNext: { [weak self] profile in
                self?.imageUrl.accept(.init(string: profile?.imageUrl ?? ""))
                self?.buttonImage.onNext((profile?.active == true) ? R.image.checkedCircleIcon() : R.image.removeIcon())
                self?.buttonBackgroundColor.onNext((profile?.active == true) ? UIColor(hexString: "#2979FF") : UIColor(hexString: "#F35050").withAlphaComponent(0.58))
            }) ~ self.disposeBag
        
        self.isSelected.asObservable()
            .subscribe(onNext: { [weak self] isSelected in
                let borderColor: UIColor = isSelected ? .color(.primary) : .color(.shimmering).withAlphaComponent(0.5)
                let borderWidth: CGFloat = isSelected ? 3 : 1
                self?.border.onNext((borderColor, borderWidth))
            }) ~ self.disposeBag
    }
}
