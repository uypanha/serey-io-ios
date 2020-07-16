//
//  Tag.swift
//  SwiftySteem
//
//  Created by Benedikt Veith on 22.02.18.
//  Copyright © 2018 benedikt-veith. All rights reserved.
//

import Foundation

struct GetTrendingTags: Codable {
    let jsonrpc: String
    let id: Int
    let method: String
    let params: [String]
}

struct GetDiscussionsBy: Codable {
    let jsonrpc: String
    let id: Int
    let method: String
    let params: [QueryDiscussionsBy]
}

public struct QueryDiscussionsBy: Codable {
    var tag: String? = nil
    var start_author: String? = nil
    var start_permlink: String? = nil
    var limit: Int = Constants.limitPerPage
    
    public init(tag: String? = nil, start_author: String? = nil, start_permlink: String? = nil, limit: Int = Constants.limitPerPage) {
        self.tag = tag
        self.start_author = start_author
        self.start_permlink = start_permlink
        self.limit = limit
    }
}

// FUTURE USAGE EXAMPLE

struct ResponseGetTrendingTags: Decodable {
    let id: Int
    let result: [TrendingTag]
}

struct TrendingTag: Decodable {
    let name: String
    let total_payouts: String
    let net_votes: Int
    let top_posts: Int
    let comments: Int
    let trending: String
}
