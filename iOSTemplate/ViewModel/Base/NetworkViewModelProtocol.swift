//
//  NetworkViewModelProtocol.swift
//  iOSTemplate
//
//  Created by Phanha Uy on 1/11/20.
//  Copyright © 2020 Phanha Uy. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift

protocol NetworkViewModelProtocol {
    
    func downloadData()
}

protocol DownloadStateNetworkProtocol: NetworkViewModelProtocol {
    
    var isDownloading: BehaviorRelay<Bool> { get }
}

// MARK: Infinite Network Protocol
protocol InfiniteNetworkProtocol: DownloadStateNetworkProtocol {
    
    var canDownloadMorePages: BehaviorRelay<Bool> { get }
    var isRefresh: Bool { get set }
    var pageModel: PaginationRequestModel { get set }
    var downloadDisposeBag: DisposeBag { get set }
    
    func canDownloadMore() -> Bool
    
    mutating func reset()
}

extension InfiniteNetworkProtocol {
    
    func canDownloadMore() -> Bool {
        return self.canDownloadMorePages.value
    }
    
    mutating func reset() {
        self.canDownloadMorePages.accept(true)
        self.pageModel.page = 1
        self.isRefresh = true
        self.isDownloading.accept(false)
        self.downloadDisposeBag = DisposeBag()
        self.downloadData()
    }
}
