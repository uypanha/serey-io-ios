//
//  ProfileOption.swift
//  SereyIO
//
//  Created by Mäd on 27/12/2021.
//  Copyright © 2021 Serey IO. All rights reserved.
//

import UIKit

enum ProfileOption: CaseIterable {
    
    case selectFromGallery
    case uploadNewPicture
    
    var icon: UIImage? {
        switch self {
        case .selectFromGallery:
            return R.image.galleryIcon()
        case .uploadNewPicture:
            return R.image.uploadProfileIcon()
        }
    }
    
    var title: String {
        switch self {
        case .selectFromGallery:
            return "Select from gallery"
        case .uploadNewPicture:
            return "Upload new picture"
        }
    }
    
    var cellModel: ProfilePictureOptionCellViewModel {
        return ProfilePictureOptionCellViewModel(self)
    }
}

class ProfilePictureOptionCellViewModel: ImageTextCellViewModel {
    
    let option: ProfileOption
    
    init(_ option: ProfileOption) {
        self.option = option
        super.init(model: .init(image: option.icon, titleText: option.title))
        
        self.showSeperatorLine.onNext(false)
    }
}
