//
//  CommentReplyModel.swift
//  SereyIO
//
//  Created by Panha Uy on 4/25/20.
//  Copyright © 2020 Serey IO. All rights reserved.
//

import UIKit

struct CommentReplyModel: Codable {
    
    let author: String
    let reputation: Int
    let title: String
    let permlink: String
    let votes: Int
    let children: Int
    let category: String
    let date: String
    let body: String
    let url: String
    let payout: PayoutModel
    
    var publishedDateString: String? {
        get {
            guard let date = Date.date(from: self.date, format: "yyyy-MM-dd HH:mm") else { return nil }
            
            return date.timeAgo(to: Date())
        }
    }
    
    var profileViewModel: ProfileViewModel {
        get {
            let firstLetter = author.first == nil ? "" : "\(author.first!)"
            let uniqueColor = UIColor(hexString: PFColorHash().hex("\(author)"))
            return ProfileViewModel(shortcut: firstLetter, imageUrl: nil, uniqueColor: uniqueColor)
        }
    }
    
    var sereyValue: String {
        get {
            return "\(payout.total) SEREY"
        }
    }
    
    enum CodingKeys: String, CodingKey {
        case author
        case reputation
        case title
        case permlink
        case votes
        case children
        case category
        case date
        case body
        case url
        case payout
    }
}

struct PayoutModel: Codable {
    
    let total: Double
    let totalAuthor: Double
    let totalCurator: Double
    
    enum CodingKeys: String, CodingKey {
        case total
        case totalAuthor = "total_author_payout"
        case totalCurator = "total_curator_payout"
    }
}
