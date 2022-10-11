//
//  DrumReplyCellViewModel.swift
//  SereyIO
//
//  Created by Panha Uy on 25/7/22.
//  Copyright © 2022 Serey IO. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift
import RxBinding

class DrumReplyCellViewModel: CellViewModel, ShouldReactToAction {
    
    enum Action {
        case profilePressed
        case commentPressed
        case votePressed
    }
    
    // input:
    let didActionSubject: PublishSubject<Action>
    
    let reply: BehaviorRelay<PostModel?>
    
    let profileModel: BehaviorSubject<ProfileViewModel?>
    let profileName: BehaviorSubject<String?>
    let createdAt: BehaviorSubject<String?>
    let descriptionText: BehaviorSubject<String?>
    let commentCount: BehaviorSubject<String?>
    let likeCount: BehaviorSubject<String?>
    let isVoteEnabled: BehaviorRelay<Bool>
    
    let isVoting: BehaviorSubject<VotedType?>
    let didPostActionPressed: PublishSubject<(DrumsPostCellViewModel.DrumAction, PostModel)>
    
    let isShimmering: BehaviorRelay<Bool>
    
    init(reply: PostModel? = nil) {
        self.didActionSubject = .init()
        
        self.reply = .init(value: reply)
        self.profileModel = .init(value: reply?.profileViewModel)
        self.profileName = .init(value: reply?.author ?? "    ")
        self.createdAt = .init(value: reply?.publishedDateString ?? "     ")
        self.descriptionText = .init(value: reply?.descriptionText?.htmlToString.trimmingCharacters(in: .newlines) ?? "    ")
        let likeCount = reply?.voterCount ?? 0
        self.likeCount = .init(value: likeCount == 0 ? "" : "\(likeCount)")
        
        let commentCount: Int = reply?.replies?.count ?? 0
        self.commentCount = .init(value: commentCount == 0 ? nil : "\(commentCount)")
        self.isVoteEnabled = .init(value: reply?.allowVote ?? false)
        self.isShimmering = .init(value: reply == nil)
        
        self.isVoting = .init(value: nil)
        self.didPostActionPressed = .init()
        super.init()
        
        setUpRxObservers()
    }
}

// MARK: - SetUp RxObservers
private extension DrumReplyCellViewModel {
    
    func setUpRxObservers() {
        setUpActionObservers()
    }
    
    func setUpActionObservers() {
        self.didActionSubject.asObservable()
            .subscribe(onNext: { [weak self] action in
                switch action {
                case .profilePressed:
                    break
                case .commentPressed:
                    break
                case .votePressed:
                    if let drum = self?.reply.value, self?.isVoteEnabled.value == true, let _self = self {
                        self?.didPostActionPressed.onNext((.vote(drum.votedType, _self.isVoting), drum))
                    }
                }
            }) ~ self.disposeBag
    }
}
