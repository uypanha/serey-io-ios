//
//  PostCellProtocol.swift
//  SereyIO
//
//  Created by Panha Uy on 4/20/20.
//  Copyright © 2020 Serey IO. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift
import RxBinding

protocol PostCellProtocol {
    
    var post: BehaviorRelay<PostModel?> { get }
    var shouldUpVote: PublishSubject<PostModel> { get }
    var shouldFlag: PublishSubject<PostModel> { get }
    var shouldDownvote: PublishSubject<(VotedType, PostModel)> { get }
    
    var votedType: BehaviorRelay<VotedType?> { get }
    var upVoteEnabled: BehaviorSubject<Bool> { get }
    var flagEnabled: BehaviorSubject<Bool> { get }
    var isVoting: BehaviorSubject<VotedType?> { get }
}

enum VotedType {
    case upvote
    case flag
}
