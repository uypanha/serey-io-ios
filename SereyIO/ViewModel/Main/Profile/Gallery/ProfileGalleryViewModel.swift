//
//  ProfileGalleryViewModel.swift
//  SereyIO
//
//  Created by Mäd on 27/12/2021.
//  Copyright © 2021 Serey IO. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift
import RxBinding

class ProfileGalleryViewModel: BaseUserProfileViewModel, CollectionSingleSecitionProviderModel, DownloadStateNetworkProtocol, ShouldReactToAction, ShouldPresent {
    
    enum Action {
        case itemSelected(IndexPath)
        case updatePressed
    }
    
    enum ViewToPresent {
        case openMediaPicker
        case showAlertDialog(AlertDialogModel)
        case loading(Bool, String?)
        case dismiss
    }
    
    // input:
    let didActionSubject: PublishSubject<Action>
    
    // output:
    let shouldPresentSubject: PublishSubject<ViewToPresent>
    
    let profiles: BehaviorRelay<[UserProfileModel]>
    let selectedProfile: BehaviorRelay<UserProfileModel?>
    let cells: BehaviorRelay<[CellViewModel]>
    let isUpdateButonHidden: BehaviorSubject<Bool>
    
    let isDescriptionHidden: BehaviorSubject<Bool>
    let isDownloading: BehaviorRelay<Bool>
    
    init() {
        self.didActionSubject = .init()
        self.shouldPresentSubject = .init()
        
        self.cells = .init(value: [])
        self.profiles = .init(value: [])
        self.selectedProfile = .init(value: nil)
        self.isUpdateButonHidden = .init(value: true)
        
        self.isDescriptionHidden = .init(value: false)
        self.isDownloading = .init(value: false)
        super.init(AuthData.shared.username ?? "")
        
        setUpRxObservers()
    }
}

// MARK: - Networks
extension ProfileGalleryViewModel {
    
    func downloadData() {
        if !self.isDownloading.value {
            self.isDownloading.accept(true)
            self.getAllUserProfilePicture { profiles in
                self.isDownloading.accept(false)
                self.profiles.accept(profiles)
            }
        }
    }
}

// MAKR: - Preparations & Tools
extension ProfileGalleryViewModel {
    
    func prepareCells() -> [CellViewModel] {
        var items: [CellViewModel] = []
        if self.isDownloading.value || !self.profiles.value.isEmpty {
            items.append(UploadProfileCellViewModel())
        }
        items.append(contentsOf: self.profiles.value.map { ProfilePictureCellViewModel($0, self.selectedProfile) })
        return items
    }
    
    func updateActiveData(_ data: UserProfileModel) {
        var profiles = self.profiles.value.filter { $0.id != data.id }
        profiles.forEach { profile in
            profile.active = false
        }
        profiles.insert(data, at: 0)
        self.profiles.accept(profiles)
    }
}

// MARK: - Preparations & Tools
extension ProfileGalleryViewModel {
    
    func handleItemSelected(_ indexPath: IndexPath) {
        if let _ = self.item(at: indexPath) as? UploadProfileCellViewModel {
            self.shouldPresent(.openMediaPicker)
        } else if let item = self.item(at: indexPath) as? ProfilePictureCellViewModel {
            self.selectedProfile.accept(item.profile.value)
        }
    }
    
    func handleUpdatePressed() {
        if let selectedProfile = self.selectedProfile.value {
            self.isUploading.accept(true)
            self.changeProfile(selectedProfile.id) { data in
                self.updateActiveData(data)
                self.shouldPresent(.dismiss)
            }
        }
    }
}

// MARK: - SetUp RxObservers
extension ProfileGalleryViewModel {
    
    func setUpRxObservers() {
        setUpContentChangedObservers()
        setUpActionObservers()
    }
    
    func setUpContentChangedObservers() {
        self.profiles.asObservable()
            .map { _ in self.prepareCells() }
            ~> self.cells
            ~ self.disposeBag
        
        self.selectedProfile.asObservable()
            .map { $0 == nil || self.profiles.value.first(where: { $0.active })?.id == $0?.id }
            ~> self.isUpdateButonHidden
            ~ self.disposeBag
        
        self.isUploading.asObservable()
            .map { ViewToPresent.loading($0, "Changing...") }
            ~> self.shouldPresentSubject
            ~ self.disposeBag
    }
    
    func setUpActionObservers() {
        self.didActionSubject.asObservable()
            .subscribe(onNext: { [weak self] action in
                switch action {
                case .itemSelected(let indexPath):
                    self?.handleItemSelected(indexPath)
                case .updatePressed:
                    self?.handleUpdatePressed()
                }
            }) ~ self.disposeBag
    }
}
