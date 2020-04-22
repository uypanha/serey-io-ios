//
//  VoteDialogViewModel.swift
//  SereyIO
//
//  Created by Panha Uy on 4/16/20.
//  Copyright © 2020 Phanha Uy. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift
import RxBinding

class VoteDialogViewModel: BaseViewModel, ShouldReactToAction {
    
    enum VoteType {
        case upVoteComment
        case flagComment
        case upvotePost
        case flagPost
        
        var minusText: String {
            switch self {
            case .flagComment, .flagPost:
                return "-"
            default:
                return ""
            }
        }
        
        var title: String {
            switch self {
            case .upvotePost:
                return "Upvote Post"
            case .upVoteComment:
                return "Upvote Comment"
            case .flagComment:
                return "Flag Comment"
            default:
                return "Flag Post"
            }
        }
    }
    
    enum Action {
        case confirmPressed
    }
    
    lazy var didActionSubject = PublishSubject<Action>()
    
    let voteType: BehaviorRelay<VoteType>
    let voteCount: BehaviorRelay<Float>
    
    let titleText: BehaviorSubject<String?>
    let pregressText: BehaviorSubject<String?>
    
    let shouldConfirm: PublishSubject<Int>
    
    init(_ currentVote: Float, type: VoteType) {
        self.voteType = BehaviorRelay(value: type)
        self.voteCount = BehaviorRelay(value: currentVote)
        self.titleText = BehaviorSubject(value: nil)
        self.pregressText = BehaviorSubject(value: nil)
        self.shouldConfirm = PublishSubject()
        super.init()
        
        setUpRxObservers()
    }
}

// MARK: - Preparations & Tools
extension VoteDialogViewModel {
    
    func prepareVoteText(_ count: Float) -> String {
        return "\(self.voteType.value.minusText)\(Int(count))"
    }
}

// MARK: - SetUp RxObservers
fileprivate extension VoteDialogViewModel {
    
    func setUpRxObservers() {
        setUpContentChangedObservers()
        setUpActionObservers()
    }
    
    func setUpContentChangedObservers() {
        self.voteCount.asObservable()
            .map { self.prepareVoteText($0) }
            .bind(to: self.pregressText)
            ~ self.disposeBag
        
        self.voteType.asObservable()
            .map { $0.title }
            ~> self.titleText
            ~ self.disposeBag
    }
    
    func setUpActionObservers() {
        self.didActionSubject.asObservable()
            .subscribe(onNext: { [weak self] action in
                switch action {
                case .confirmPressed:
                    let voteCount = Int(self?.voteCount.value ?? 0)
                    self?.shouldConfirm.onNext(voteCount)
                }
            }) ~ self.disposeBag
    }
}
