//
//  PostModel.swift
//  SereyIO
//
//  Created by Phanha Uy on 2/27/20.
//  Copyright © 2020 Phanha Uy. All rights reserved.
//

import UIKit

struct PostModel: Codable {
    
    let id: Int
    let title: String
    let permlink: String
    let description: String?
    let shortDesc: String?
    let authorName: String
    let categoryItem: [String]
    let answerCount: Int
    let publishDate: String
    let sereyValue: String
    let upvote: Int
    let voter: [String]
    let flag: Int
    let flagger: [String]
    let imageUrl: [String]?
    var replies: [PostModel]?
    
    var firstThumnailURL: URL? {
        get {
            return imageUrl?.first == nil ? nil : URL(string: imageUrl!.first!)
        }
    }
    
    var publishedDateString: String? {
        get {
            guard let date = Date.date(from: self.publishDate, format: "yyyy-MM-dd HH:mm") else { return nil }
            
            return date.timeAgo(to: Date())
        }
    }
    
    var profileViewModel: ProfileViewModel {
        get {
            let firstLetter = authorName.first == nil ? "" : "\(authorName.first!)"
            let uniqueColor = UIColor(hexString: PFColorHash().hex("\(authorName)"))
            return ProfileViewModel(shortcut: firstLetter, imageUrl: nil, uniqueColor: uniqueColor)
        }
    }
    
    var votedType: VotedType? {
        get {
            if let loggerUserName = AuthData.shared.username {
                if self.voter.contains(where: { $0 == loggerUserName }) {
                    return .upvote
                } else if self.flagger.contains(where: { $0 == loggerUserName }) {
                    return .flag
                }
            }
            
            return nil
        }
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case title
        case permlink
        case description
        case shortDesc = "short_desc"
        case authorName
        case categoryItem
        case answerCount
        case publishDate
        case sereyValue
        case upvote
        case voter
        case flag
        case flagger
        case imageUrl
        case replies
    }
}
