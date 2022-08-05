//
//  UploadImageOption.swift
//  SereyIO
//
//  Created by Panha Uy on 4/8/22.
//  Copyright © 2022 Serey IO. All rights reserved.
//

import UIKit

enum UploadImageOption: CaseIterable {
    
    case selectFromPhotos
    case takeNewPhoto
    
    var icon: UIImage? {
        switch self {
        case .selectFromPhotos:
            return R.image.galleryIcon()
        case .takeNewPhoto:
            return R.image.cameraIcon()
        }
    }
    
    var title: String {
        switch self {
        case .selectFromPhotos:
            return "Select from Photos"
        case .takeNewPhoto:
            return "Take Photo"
        }
    }
    
    var cellModel: UploadImageOptionCellViewModel {
        return UploadImageOptionCellViewModel(self)
    }
}


class UploadImageOptionCellViewModel: ImageTextCellViewModel {
    
    let option: UploadImageOption
    
    init(_ option: UploadImageOption) {
        self.option = option
        super.init(model: .init(image: option.icon, titleText: option.title))
        
        self.showSeperatorLine.onNext(false)
    }
}
