//
//  PostModel.swift
//  SereyIO
//
//  Created by Phanha Uy on 2/27/20.
//  Copyright © 2020 Serey IO. All rights reserved.
//

import UIKit

struct PostModel: Codable {
    
    let id: String
    let parentAuthor: String?
    let parentPermlink: String?
    let title: String
    let permlink: String
    let descriptionText: String?
    let body: String?
    let shortDesc: String?
    let author: String
    let categories: [String]?
    let answerCount: Int?
    let publishDate: String
    let sereyValue: String
    let voters: [String]
    let flaggers: [String]
    let imageUrl: [String]?
    let voterCount: Int
    let flaggerCount: Int
    let allowVote: Bool
    let authorImageUrl: String?
    var replies: [PostModel]?
    
    var isHidden: Bool = false
    
    var firstThumnailURL: URL? {
        get {
            return imageUrl?.first == nil ? nil : URL(string: imageUrl!.first!)
        }
    }
    
    var isVoted: Bool {
        return self.voters.first(where: { $0 == AuthData.shared.username }) != nil
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
                if self.voters.contains(where: { $0 == loggerUserName }) {
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
    
    enum CodingKeys: String, CodingKey {
        case id
        case parentAuthor = "parent_author"
        case parentPermlink = "parent_permlink"
        case title
        case author
        case permlink
        case descriptionText = "description"
        case body
        case shortDesc = "short_desc"
        case categories
        case answerCount = "answer_count"
        case publishDate = "publish_date"
        case sereyValue = "serey_value"
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
