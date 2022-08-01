//
//  QuotedDrumCellViewModel.swift
//  SereyIO
//
//  Created by Panha Uy on 15/7/22.
//  Copyright © 2022 Serey IO. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift
import RxBinding

class QuotedDrumCellViewModel: CellViewModel, CollectionSingleSecitionProviderModel {
    
    let post: BehaviorRelay<DrumModel>
    let cells: BehaviorRelay<[CellViewModel]>
    
    let profileModel: BehaviorSubject<ProfileViewModel?>
    let profileName: BehaviorSubject<String?>
    let createdAt: BehaviorSubject<String?>
    let descriptionText: BehaviorSubject<String?>
    
    init(_ drum: DrumModel) {
        self.post = .init(value: drum)
        self.cells = .init(value: [])
        
        self.profileModel = .init(value: drum.postProfileViewModel)
        self.profileName = .init(value: drum.postAuthor)
        self.createdAt = .init(value: drum.postPublishedDateString ?? drum.publishedDateString)
        self.descriptionText = .init(value: drum.postDescription?.htmlToString ?? drum.descriptionText?.htmlToString)
        super.init()
        
        self.cells.accept(self.prepareCells())
    }
}

// MARK: - Preparations & Tools
extension QuotedDrumCellViewModel {
    
    private func prepareCells() -> [CellViewModel] {
        var items: [CellViewModel] = []
        
        let drum = self.post.value
        let imageCount = drum.postImageUrl.count
        let images = drum.postImageUrl.prefix(2)
        items.append(contentsOf: images.map { ImageCellViewModel($0) })
        if imageCount > 2 {
            (items.last as? ImageCellViewModel)?.plusImage.accept(imageCount - images.count)
        }
        return items
    }
    
    func size(forCell at: IndexPath, maxWidth: CGFloat) -> CGSize {
        if let _ = self.item(at: at) as? ImageCellViewModel {
            let width: CGFloat = (self.post.value.postImageUrl.count > 1) ? (maxWidth / 2) - 4 : maxWidth
            let height: CGFloat = width * 0.55
            return .init(width: width, height: height)
        }
        return .init(width: maxWidth, height: 50)
    }
    
    func maxHeight(with maxWidth: CGFloat) -> CGFloat {
        let width: CGFloat = (self.post.value.postImageUrl.count > 1) ? (maxWidth / 2) - 4 : maxWidth
        let height: CGFloat = width * 0.55
        return height
    }
}
