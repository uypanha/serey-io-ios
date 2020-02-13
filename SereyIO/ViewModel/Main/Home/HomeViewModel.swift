//
//  HomeViewModel.swift
//  SereyIO
//
//  Created by Phanha Uy on 2/6/20.
//  Copyright © 2020 Phanha Uy. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift
import RxBinding

class HomeViewModel: BaseViewModel {
    
    let postTabTitles: BehaviorRelay<[String]>
    let postViewModels: BehaviorRelay<[PostTableViewModel]>
    
    override init() {
        self.postTabTitles = BehaviorRelay(value: [])
        self.postViewModels = BehaviorRelay(value: [])
        super.init()
        
        self.postTabTitles.accept(PostTabType.allCases.map { $0.title })
        self.postViewModels.accept(PostTabType.allCases.map { $0.viewModel })
    }
}

// MARK: - PostTabType
enum PostTabType: CaseIterable {
    case trending
    case hot
    case new
    
    var title: String {
        switch self {
        case .trending:
            return "TRENDING"
        case .hot:
            return "HOT"
        case .new:
            return "NEW"
        }
    }
    
    var viewModel: PostTableViewModel {
        return PostTableViewModel(self)
    }
}

