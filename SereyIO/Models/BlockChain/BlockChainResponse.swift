//
//  BlockChainResponse.swift
//  SereyIO
//
//  Created by Panha Uy on 4/2/20.
//  Copyright © 2020 Phanha Uy. All rights reserved.
//

import Foundation

struct BlockChainResponse: Codable {
    
    let blockChainData: BlockChainModel
    
    enum CodingKeys: String, CodingKey {
        case blockChainData = "blockchain_data"
    }
}

struct BlockChainModel: Codable {
    
    let result: SubmitResultModel
    
    enum CodingKeys: String, CodingKey {
        case result
    }
}

struct SubmitResultModel: Codable {
    
    let id: String
    let blockNumber: Int
    let trxNumber: Int
    let expired: Bool
    let refBlockNumber: Int
    let refBlockPrefix: ULONG
    let expiration: String
//    let operations: [[OperationModel]]
    let signatures: [String]
    
    enum CodingKeys: String, CodingKey {
        case id
        case blockNumber = "block_num"
        case trxNumber = "trx_num"
        case expired
        case refBlockNumber = "ref_block_num"
        case refBlockPrefix = "ref_block_prefix"
        case expiration
//        case operations
        case signatures
    }
}

struct OperationModel: Codable {
    
    let comment: BlockCommentModel?
    
    enum CodingKeys: String, CodingKey {
        case comment
    }
}

struct BlockCommentModel: Codable {
    
    let parentAuthor: String
    let parentPermlink: String
    let author: String
    let permlink: String
    let title: String
    let body: String
    let jsonMetadata: String
    
    enum CodingKeys: String, CodingKey {
        case parentAuthor = "parent_author"
        case parentPermlink = "parent_permlink"
        case author
        case permlink
        case title
        case body
        case jsonMetadata = "json_metadata"
    }
}
