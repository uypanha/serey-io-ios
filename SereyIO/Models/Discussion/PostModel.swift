//
//  PostModel.swift
//  SereyIO
//
//  Created by Phanha Uy on 2/27/20.
//  Copyright © 2020 Serey IO. All rights reserved.
//

import UIKit
import AnyCodable

struct PostModel: Codable {
    
    let idValue: AnyCodable
    let parentAuthor: String?
    let parentPermlink: String?
    let title: String
    let permlink: String
    let descriptionText: String?
    let body: String?
    let shortDesc: String?
    let authorValue: AnyCodable?
    let authorName: String?
    let categories: [String]?
    let answerCount: Int?
    let publishDate: String
    let sereyValue: String
    let voters: [String]?
    let flaggers: [String]
    let imageUrl: [String]?
    let voterCount: Int
    let flaggerCount: Int
    let allowVote: Bool
    let authorImageUrl: String?
    var replies: [PostModel]?
    
    var id: String {
        return (self.idValue.value as? String) ?? (self.idValue.value as? Int)?.description ?? ""
    }
    
    var author: String {
        return self.authorValue?.value as? String ?? self.authorName ?? ""
    }
    
    var isHidden: Bool = false
    
    var firstThumnailURL: URL? {
        get {
            return imageUrl?.first == nil ? nil : URL(string: imageUrl!.first!)
        }
    }
    
    var isVoted: Bool {
        return self.voters?.first(where: { $0 == AuthData.shared.username }) != nil
    }
    
    var isFlagged: Bool {
        return self.flaggers.first(where: { $0 == AuthData.shared.username }) != nil
    }
    
    var publishedDateString: String? {
        get {
            guard let date = Date.date(from: self.publishDate, format: "yyyy-MM-dd HH:mm") else { return nil }
            
            if (date.daysCount(to: Date()) < 7) {
                return date.timeAgo(to: Date())
            }
            
            return date.format("MMM, dd yyyy")
        }
    }
    
    var isOverAWeek: Bool {
        get {
            guard let date = Date.date(from: self.publishDate, format: "yyyy-MM-dd HH:mm") else { return false }
            
            return date.daysCount(to: Date()) > 7
        }
    }
    
    var profileViewModel: ProfileViewModel {
        let firstLetter = author.first == nil ? "" : "\(author.first!)"
        let uniqueColor = UIColor(hexString: PFColorHash().hex("\(author)"))
        
//        let predicate = NSPredicate(format: "active == true AND username == %@", self.author)
//        let defaultImage: UserProfileModel? = UserProfileModel().qeuryFirst(by: predicate)
        let url = URL(string: self.authorImageUrl ?? "")
        return ProfileViewModel(shortcut: firstLetter, imageUrl: url, uniqueColor: uniqueColor)
    }
    
    var votedType: VotedType? {
        get {
            if let loggerUserName = AuthData.shared.username {
                if self.voters?.contains(where: { $0 == loggerUserName }) == true {
                    return .upvote
                } else if self.flaggers.contains(where: { $0 == loggerUserName }) {
                    return .flag
                }
            }
            
            return nil
        }
    }
    
    func prepareOptionMenuTitle() -> String {
        if self.author != AuthData.shared.username {
            return "How can we help?"
        }
        return " "
    }
    
    func prepareOptionMenu() -> [PostMenu] {
        var menu: [PostMenu] = []
        if self.author == AuthData.shared.username {
            menu.append(.edit)
            if voterCount == 0 {
                menu.append(.delete)
            }
        } else {
            menu.append(.hidePost)
            menu.append(.reportPost)
        }
        return menu
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.idValue, forKey: .idValue)
        try container.encodeIfPresent(self.parentAuthor, forKey: .parentAuthor)
        try container.encodeIfPresent(self.parentPermlink, forKey: .parentPermlink)
        try container.encode(self.title, forKey: .title)
        try container.encodeIfPresent(self.authorValue, forKey: .authorValue)
        try container.encodeIfPresent(self.authorName, forKey: .authorName)
        try container.encode(self.permlink, forKey: .permlink)
        try container.encodeIfPresent(self.descriptionText, forKey: .descriptionText)
        try container.encodeIfPresent(self.body, forKey: .body)
        try container.encodeIfPresent(self.shortDesc, forKey: .shortDesc)
        try container.encodeIfPresent(self.categories, forKey: .categories)
        try container.encodeIfPresent(self.answerCount, forKey: .answerCount)
        try container.encode(self.publishDate, forKey: .publishDate)
        try container.encode(self.sereyValue, forKey: .sereyValue)
        try container.encode(self.voters, forKey: .voters)
        try container.encode(self.flaggers, forKey: .flaggers)
        try container.encodeIfPresent(self.imageUrl, forKey: .imageUrl)
        try container.encode(self.allowVote, forKey: .allowVote)
        try container.encode(self.voterCount, forKey: .voterCount)
        try container.encode(self.flaggerCount, forKey: .flaggerCount)
        try container.encodeIfPresent(self.authorImageUrl, forKey: .authorImageUrl)
        try container.encodeIfPresent(self.replies, forKey: .replies)
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.idValue = try container.decode(AnyCodable.self, forKey: .idValue)
        self.parentAuthor = try container.decodeIfPresent(String.self, forKey: .parentAuthor)
        self.parentPermlink = try container.decodeIfPresent(String.self, forKey: .parentPermlink)
        self.title = try container.decode(String.self, forKey: .title)
        self.authorValue = try container.decodeIfPresent(AnyCodable.self, forKey: .authorValue)
        self.authorName = try container.decodeIfPresent(String.self, forKey: .authorName)
        self.permlink = try container.decode(String.self, forKey: .permlink)
        self.descriptionText = try container.decodeIfPresent(String.self, forKey: .descriptionText)
        self.body = try container.decodeIfPresent(String.self, forKey: .body)
        self.shortDesc = try container.decodeIfPresent(String.self, forKey: .shortDesc)
        self.categories = try container.decodeIfPresent([String].self, forKey: .categories)
        self.answerCount = try container.decodeIfPresent(Int.self, forKey: .answerCount)
        self.publishDate = ((try? container.decodeIfPresent(String.self, forKey: .publish_date)) ?? (try? container.decodeIfPresent(String.self, forKey: .publishDate)) ?? "") ?? ""
        self.sereyValue = ((try? container.decodeIfPresent(String.self, forKey: .serey_value)) ?? (try? container.decodeIfPresent(String.self, forKey: .sereyValue)) ?? "") ?? ""
        self.voters = try container.decode([String].self, forKey: .voters)
        self.flaggers = try container.decode([String].self, forKey: .flaggers)
        self.imageUrl = try container.decodeIfPresent([String].self, forKey: .imageUrl)
        self.allowVote = try container.decode(Bool.self, forKey: .allowVote)
        self.voterCount = try container.decode(Int.self, forKey: .voterCount)
        self.flaggerCount = try container.decode(Int.self, forKey: .flaggerCount)
        self.authorImageUrl = try container.decodeIfPresent(String.self, forKey: .authorImageUrl)
        self.replies = try container.decodeIfPresent([PostModel].self, forKey: .replies)
    }
    
    enum CodingKeys: String, CodingKey {
        case idValue = "id"
        case parentAuthor = "parent_author"
        case parentPermlink = "parent_permlink"
        case title
        case authorValue = "author"
        case authorName = "authorName"
        case permlink
        case descriptionText = "description"
        case body
        case shortDesc = "short_desc"
        case categories
        case answerCount = "answer_count"
        case publish_date = "publish_date"
        case publishDate = "publishDate"
        case serey_value = "serey_value"
        case sereyValue = "sereyValue"
        case voters
        case flaggers
        case imageUrl = "image_url"
        case allowVote = "allow_vote"
        case voterCount = "voter_count"
        case flaggerCount = "flagger_count"
        case authorImageUrl = "author_image_url"
        case replies
    }
}
