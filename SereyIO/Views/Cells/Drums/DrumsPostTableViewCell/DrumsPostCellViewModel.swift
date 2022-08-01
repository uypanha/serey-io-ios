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

class DrumsPostCellViewModel: CellViewModel, ShimmeringProtocol, CollectionSingleSecitionProviderModel, ShouldReactToAction {
    
    enum Action {
        case profilePressed
        case commentPressed
        case votePressed
        case redrumQuotePressed
        case itemSelected(IndexPath)
    }
    
    // input:
    let didActionSubject: PublishSubject<Action>
    
    let post: BehaviorRelay<DrumModel?>
    let isShimmering: BehaviorRelay<Bool>
    
    let redrummedBy: BehaviorSubject<String?>
    let profileModel: BehaviorSubject<ProfileViewModel?>
    let profileName: BehaviorSubject<String?>
    let createdAt: BehaviorSubject<String?>
    let title: BehaviorSubject<String?>
    let descriptionHtml: BehaviorSubject<String?>
    let isVoteEnabled: BehaviorSubject<Bool>
    
    let commentCount: BehaviorSubject<String?>
    let likeCount: BehaviorSubject<String?>
    
    let redrumButtonColor: BehaviorSubject<UIColor>
    
    let cells: BehaviorRelay<[CellViewModel]>
    
    let didProfilePressed: PublishSubject<String>
    let didQuotedPostPressed: PublishSubject<DrumModel>
    let didPostActionPressed: PublishSubject<(DrumAction, DrumModel)>
    
    init(_ post: DrumModel? = nil) {
        self.didActionSubject = .init()
        self.post = .init(value: post)
        self.isShimmering = .init(value: post == nil)
        
        self.redrummedBy = .init(value: post?.redrummedBy)
        self.redrumButtonColor = .init(value: post?.isLoggedUserRedrummed == true ? .color("#F2F8FD") : .color("#E1E1E1"))
        self.profileModel = .init(value: post?.profileViewModel)
        self.profileName = .init(value: post?.author ?? "    ")
        self.createdAt = .init(value: post?.publishedDateString ?? "    ")
        self.title = .init(value: post?.title.trimmingCharacters(in: .newlines) ?? "   ")
        self.descriptionHtml = .init(value: post?.descriptionText ?? "   ")
        let likeCount = post?.voterCount ?? 0
        self.likeCount = .init(value: likeCount == 0 ? "" : "\(likeCount)")
        
        let commentCount: Int = post?.answerCount ?? 0
        self.commentCount = .init(value: commentCount == 0 ? nil : "\(commentCount)")
        
        self.isVoteEnabled = .init(value: post?.allowVote ?? false)
        
        self.cells = .init(value: [])
        self.didProfilePressed = .init()
        self.didQuotedPostPressed = .init()
        self.didPostActionPressed = .init()
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
    
    enum DrumAction {
        case comment
        case redrum
        case vote
    }
    
    private func notifyDataChanaged(_ data: DrumModel?) {
        self.redrummedBy.onNext(data?.redrummedBy)
        self.redrumButtonColor.onNext(data?.isLoggedUserRedrummed == true ? .color("#F2F8FD") : .color("#E1E1E1"))
        self.profileModel.onNext(data?.profileViewModel)
        self.profileName.onNext(data?.author ?? "    ")
        self.createdAt.onNext(data?.publishedDateString ?? "      ")
        self.title.onNext(data?.descriptionText?.htmlToString ?? "       ")
        self.descriptionHtml.onNext(data?.descriptionText ?? "      ")
        let likeCount = data?.voterCount ?? 0
        self.likeCount.onNext(likeCount == 0 ? "" : "\(likeCount)")
    }
    
    private func prepareCells() -> [CellViewModel] {
        var items: [CellViewModel] = []
        if let post = self.post.value {
            let imageCount = post.imageUrl?.count ?? 0
            let images = post.imageUrl?.prefix(2) ?? []
            items.append(contentsOf: images.map { ImageCellViewModel($0) })
            if (post.imageUrl?.count ?? 0) > 2 {
                (items.last as? ImageCellViewModel)?.plusImage.accept(imageCount - images.count)
            }
            
            if post.postAuthor != nil {
                items.append(QuotedDrumCellViewModel(post))
            }
        }
        return items
    }
    
    func size(forCell at: IndexPath, maxWidth: CGFloat) -> CGSize {
        if let _ = self.item(at: at) as? ImageCellViewModel {
            let width: CGFloat = (self.post.value?.imageUrl?.count ?? 0 > 1) ? (maxWidth / 2) - 4 : maxWidth
            let height: CGFloat = width * 0.55
            return .init(width: width, height: height)
        }
        
        if let _ = self.item(at: at) as? QuotedDrumCellViewModel {
            return .init(width: maxWidth, height: 100)
        }
        return .init(width: maxWidth, height: 94)
    }
    
    func minHeight(with maxWidth: CGFloat) -> CGFloat {
        var height: CGFloat = 0
        let imageCount = self.post.value?.imageUrl?.count ?? 0
        if imageCount > 0 {
            let width: CGFloat = (imageCount > 1) ? (maxWidth / 2) - 4 : maxWidth
            height += width * 0.55
        }
        
        if self.post.value?.postAuthor != nil {
            height += 100
        }
        
        return height
    }
    
    func update(drum: DrumModel?) {
        self.post.accept(drum)
        self.isShimmering.accept(drum == nil)
    }
}

fileprivate extension DrumsPostCellViewModel {
    
    func handleProfilePressed() {
        if let author = self.post.value?.author {
            self.didProfilePressed.onNext(author)
        }
    }
    
    func handleItemSelected(at indexPath: IndexPath) {
        if let item = self.item(at: indexPath) as? QuotedDrumCellViewModel {
            self.didQuotedPostPressed.onNext(item.post.value)
        }
    }
}

// MARK: - SetUp RxObservers
private extension DrumsPostCellViewModel {
    
    func setUpRxObservers() {
        setUpContentChangedObservers()
        setUpActionObservers()
    }
    
    func setUpContentChangedObservers() {
        self.post.asObservable()
            .map { _ in self.prepareCells() }
            ~> self.cells
            ~ self.disposeBag
        
        self.post.asObservable()
            .subscribe(onNext: { [weak self] data in
                self?.notifyDataChanaged(data)
            }) ~ self.disposeBag
    }
    
    func setUpActionObservers() {
        self.didActionSubject.asObservable()
            .subscribe(onNext: { [weak self] action in
                switch action {
                case .profilePressed:
                    self?.handleProfilePressed()
                case .itemSelected(let indexPath):
                    self?.handleItemSelected(at: indexPath)
                case .commentPressed:
                    if let drum = self?.post.value {
                        self?.didPostActionPressed.onNext((.comment, drum))
                    }
                case .votePressed:
                    if let drum = self?.post.value {
                        self?.didPostActionPressed.onNext((.vote, drum))
                    }
                case .redrumQuotePressed:
                    if let drum = self?.post.value {
                        self?.didPostActionPressed.onNext((.redrum, drum))
                    }
                }
            }) ~ self.disposeBag
    }
}
