//
//  DrumsPostCellViewModel.swift
//  SereyIO
//
//  Created by Panha Uy on 21/6/22.
//  Copyright © 2022 Serey IO. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift
import RxBinding

class DrumsPostCellViewModel: CellViewModel, ShimmeringProtocol, CollectionSingleSecitionProviderModel {
    
    let post: BehaviorRelay<PostModel?>
    let isShimmering: BehaviorRelay<Bool>
    
    let profileModel: BehaviorSubject<ProfileViewModel?>
    let profileName: BehaviorSubject<String?>
    let createdAt: BehaviorSubject<String?>
    let title: BehaviorSubject<String?>
    let likeCount: BehaviorSubject<String?>
    let collectionViewHeight: BehaviorSubject<CGFloat>
    
    let cells: BehaviorRelay<[CellViewModel]>
    
    init(_ post: PostModel? = nil) {
        self.post = .init(value: post)
        self.isShimmering = .init(value: post == nil)
        
        self.profileModel = .init(value: post?.profileViewModel)
        self.profileName = .init(value: post?.author ?? "    ")
        self.createdAt = .init(value: post?.publishedDateString ?? "    ")
        self.title = .init(value: post?.title ?? "   ")
        let likeCount = post?.voterCount ?? 0
        self.likeCount = .init(value: likeCount == 0 ? "" : "\(likeCount)")
        
        self.cells = .init(value: [])
        self.collectionViewHeight = .init(value: 100)
        super.init()
        
        setUpRxObservers()
    }
    
    required convenience init(_ isShimmering: Bool) {
        self.init(nil)
        
        self.isShimmering.accept(isShimmering)
    }
}

// MARK: - Preparation & Tools
extension DrumsPostCellViewModel {
    
    func prepareCells() -> [CellViewModel] {
        var items: [CellViewModel] = []
        var height: CGFloat = 0
        if let post = self.post.value {
            let imageCount = post.imageUrl?.count ?? 0
            let images = post.imageUrl?.prefix(2) ?? []
            items.append(contentsOf: images.map { ImageCellViewModel($0) })
            if (post.imageUrl?.count ?? 0) > 2 {
                (items.last as? ImageCellViewModel)?.plusImage.accept(imageCount - images.count)
            }
            
            height += imageCount > 1 ? 100 : 160
        }
        self.collectionViewHeight.onNext(height)
        return items
    }
    
    func size(forCell at: IndexPath, maxWidth: CGFloat) -> CGSize {
        if let _ = self.item(at: at) as? ImageCellViewModel {
            let width: CGFloat = (self.post.value?.imageUrl?.count ?? 0 > 1) ? (maxWidth / 2) - 4 : maxWidth
            let height: CGFloat = (self.post.value?.imageUrl?.count ?? 0 > 1) ? (100) : 160
            return .init(width: width, height: height)
        }
        return .init(width: maxWidth, height: 94)
    }
}

// MARK: - SetUp RxObservers
private extension DrumsPostCellViewModel {
    
    func setUpRxObservers() {
       setUpContentChangedObservers()
    }
    
    func setUpContentChangedObservers() {
        self.post.asObservable()
            .map { _ in self.prepareCells() }
            ~> self.cells
            ~ self.disposeBag
    }
}
