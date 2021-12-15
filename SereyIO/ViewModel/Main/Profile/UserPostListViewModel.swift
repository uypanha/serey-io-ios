//
//  UserPostListViewModel.swift
//  SereyIO
//
//  Created by Panha Uy on 12/23/20.
//  Copyright © 2020 Serey IO. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift
import RxBinding
import RxDataSources
import RealmSwift
import RxRealm

class UserPostListViewModel: PostTableViewModel {
    
    let username: String
    let drafts: Results<DraftModel>
    let draftCount: BehaviorSubject<String?>
    
    init(_ username: String) {
        self.username = username
        self.drafts = DraftModel().queryAll()
        self.draftCount = .init(value: nil)
        super.init(.byUser(username), .init(value: nil))
        
        setUpRxObservers()
    }
    
    override func prepareCells(_ discussions: [PostModel], _ error: Bool) -> [SectionItem] {
        var cells = super.prepareCells(discussions, error)
        if AuthData.shared.isUserLoggedIn && self.username == AuthData.shared.username && self.drafts.count > 0 {
            cells.insert(SectionItem(items: [DraftSavedCellViewModel(self.draftCount)]), at: 0)
        }
        return cells
    }
}

// MARK: - SetUp RxObservers
fileprivate extension UserPostListViewModel {
    
    func setUpRxObservers() {
        Observable.array(from: self.drafts)
            .map { "\($0.count)" }
            ~> self.draftCount
            ~ self.disposeBag
        
        Observable.array(from: self.drafts)
            .asObservable()
            .map { _ in  self.prepareCells(self.discussions.value, false) }
            ~> self.cells
            ~ self.disposeBag
    }
}
