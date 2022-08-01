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

class DrumReplyCellViewModel: CellViewModel {
    
    let reply: BehaviorRelay<PostModel?>
    
    let profileModel: BehaviorSubject<ProfileViewModel?>
    let profileName: BehaviorSubject<String?>
    let createdAt: BehaviorSubject<String?>
    let descriptionText: BehaviorSubject<String?>
    let commentCount: BehaviorSubject<String?>
    let likeCount: BehaviorSubject<String?>
    let isVoteEnabled: BehaviorSubject<Bool>
    
    let isShimmering: BehaviorRelay<Bool>
    
    init(reply: PostModel? = nil) {
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
        super.init()
    }
}
