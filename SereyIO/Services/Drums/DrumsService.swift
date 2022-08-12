//
//  DrumsService.swift
//  SereyIO
//
//  Created by Panha Uy on 30/6/22.
//  Copyright © 2022 Serey IO. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift
import AnyCodable

class DrumsService: AppService<DrumsApi> {
    
    func fetchAllDrums(author: String?, pagination: PaginationRequestModel) -> Observable<[DrumModel]> {
        return self.provider.rx.requestObject(.allDrums(author, pagination), type: [DrumModel].self)
            .asObservable()
    }
    
    func fetchDrumDetail(author: String, permlink: String) -> Observable<PostDetailResponse<DrumModel>> {
        return self.provider.rx.requestObject(.drumDetail(author, permlink), type: PostDetailResponse<DrumModel>.self)
            .asObservable()
    }
    
    func submitDrum(_ model: SubmitDrumPostModel) -> Observable<BlockChainResponse> {
        return self.provider.rx.requestObject(.submitDrum(model), type: DataResponseModel<BlockChainResponse>.self)
            .asObservable()
            .map { $0.data }
    }
}
