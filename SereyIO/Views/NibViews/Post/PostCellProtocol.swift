//
//  PostCellProtocol.swift
//  SereyIO
//
//  Created by Panha Uy on 4/20/20.
//  Copyright © 2020 Phanha Uy. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift
import RxBinding

protocol PostCellProtocol {
    
    var post: BehaviorRelay<PostModel?> { get }
    var shouldUpVote: PublishSubject<PostModel> { get }
    var shouldFlag: PublishSubject<PostModel> { get }
    var shouldDownvote: PublishSubject<PostModel> { get }
    
    var votedType: BehaviorRelay<VotedType?> { get }
    
}

enum VotedType {
    case upvote
    case flag
}
