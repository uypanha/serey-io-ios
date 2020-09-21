//
//  NetworkViewModelProtocol.swift
//  SereyIO
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

protocol PaginationRequestProtocol {
    
    mutating func reset()
}

// MARK: Infinite Network Protocol
protocol InfiniteNetworkProtocol: DownloadStateNetworkProtocol where P: PaginationRequestProtocol {
    associatedtype P
    
    var canDownloadMorePages: BehaviorRelay<Bool> { get }
    var isRefresh: BehaviorRelay<Bool> { get }
    var pageModel: P { get set }
    var downloadDisposeBag: DisposeBag { get set }
    
    func canDownloadMore() -> Bool
    
    mutating func reset(_ handler: @escaping () -> Void)
}

extension InfiniteNetworkProtocol {
    
    func canDownloadMore() -> Bool {
        return self.canDownloadMorePages.value
    }
    
    mutating func reset(_ handler: @escaping () -> Void = {}) {
        self.canDownloadMorePages.accept(true)
        self.pageModel.reset()
        self.isRefresh.accept(true)
        self.isDownloading.accept(false)
        self.downloadDisposeBag = DisposeBag()
        handler()
        self.downloadData()
    }
}
