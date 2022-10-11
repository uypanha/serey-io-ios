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
    
    let shouldPreviewImages: PublishSubject<MediaPreviewViewModel>
    let toQuote: Bool
    
    init(_ drum: DrumModel, toQuote: Bool = false) {
        self.toQuote = toQuote
        self.post = .init(value: drum)
        self.cells = .init(value: [])
        
        self.profileModel = .init(value: toQuote ? drum.profileViewModel : drum.postProfileViewModel)
        self.profileName = .init(value: toQuote ? drum.author : drum.postAuthor)
        self.createdAt = .init(value: toQuote ? drum.publishedDateString : (drum.postPublishedDateString ?? drum.publishedDateString))
        self.descriptionText = .init(value: toQuote ? drum.descriptionText?.htmlToString : (drum.postDescription?.htmlToString ?? drum.descriptionText?.htmlToString))
        
        self.shouldPreviewImages = .init()
        super.init()
        
        self.cells.accept(self.prepareCells())
    }
}

// MARK: - Preparations & Tools
extension QuotedDrumCellViewModel {
    
    private func prepareCells() -> [CellViewModel] {
        var items: [CellViewModel] = []
        
        let drum = self.post.value
        let imageCount = self.toQuote ? (drum.imageUrl?.count ?? 0) : drum.postImageUrl.count
        let images = self.toQuote ? (drum.imageUrl?.prefix(2) ?? []) : drum.postImageUrl.prefix(2)
        items.append(contentsOf: images.map { ImageCellViewModel($0) })
        if imageCount > 2 {
            (items.last as? ImageCellViewModel)?.plusImage.accept(imageCount - images.count)
        }
        return items
    }
    
    func size(forCell at: IndexPath, maxWidth: CGFloat) -> CGSize {
        if let _ = self.item(at: at) as? ImageCellViewModel {
            let imageCount = self.toQuote ? (self.post.value.imageUrl?.count ?? 0) : self.post.value.postImageUrl.count
            let width: CGFloat = (imageCount > 1) ? (maxWidth / 2) - 4 : maxWidth
            let height: CGFloat = width * 0.55
            return .init(width: width, height: height)
        }
        return .init(width: maxWidth, height: 50)
    }
    
    func maxHeight(with maxWidth: CGFloat) -> CGFloat {
        let imageCount = self.toQuote ? (self.post.value.imageUrl?.count ?? 0) : self.post.value.postImageUrl.count
        let width: CGFloat = (imageCount > 1) ? (maxWidth / 2) - 4 : maxWidth
        let height: CGFloat = width * 0.55
        return height
    }
}

// MARK: - Action Handlers
extension QuotedDrumCellViewModel {
    
    func handleItemSelected(_ indexPath: IndexPath) {
        if let item = self.item(at: indexPath) as? ImageCellViewModel, let imageUrl = item.imageUrl.value?.absoluteString {
            let drum = self.post.value
            let index = drum.postImageUrl.index(where: { $0 == imageUrl }) ?? 0
            let mediaPreviewModel = MediaPreviewViewModel(drum.postImageUrl, currentIndex: index)
            self.shouldPreviewImages.onNext(mediaPreviewModel)
            return
        }
    }
}
