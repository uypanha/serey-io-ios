//
//  NotificationModel.swift
//  SereyIO
//
//  Created by Panha Uy on 9/27/21.
//  Copyright © 2021 Serey IO. All rights reserved.
//

import UIKit

class NotificationModel: Codable {
    
    let id: String
    let owner: String
    let actor: String
    let type: String
    let isRead: Bool
    let information: NotificationInformationModel
    let createdAt: String
    let updatedAt: String?
    let actorImageUrl: String
    
    var isPost: Bool {
        return type == "COMMENT" || type == "VOTE"
    }
    
    var profileViewModel: ProfileViewModel {
        let firstLetter = owner.first == nil ? "" : "\(owner.first!)"
        let uniqueColor = UIColor(hexString: PFColorHash().hex("\(owner)"))
        return .init(shortcut: firstLetter, imageUrl: URL(string: actorImageUrl), uniqueColor: uniqueColor)
    }
    
    lazy var captionAttributedString: NSAttributedString? = {
        return self.prepareAttributedString()
    }()
    
    var createdTime: String? {
        return Date.date(from: self.createdAt, format: "yyyy-MM-dd'T'HH:mm:ss.ssS'Z'")?.timeCount(to: Date())
    }
    
    var postThumbnailUrl: URL? {
        return .init(string: self.information.postThubmnails?.first ?? "")
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case owner
        case actor
        case type
        case isRead = "is_read"
        case information
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case actorImageUrl = "actor_image_url"
    }
}

// MARK: - Preparations & Tools
extension NotificationModel {
    
    func prepareAttributedString() -> NSAttributedString? {
        var string: String = ""
        if type == "COMMENT" {
            string = String(format: R.string.notifications.commentedOnPost.localized(), self.actor, "your")
        } else if type == "VOTE" {
            string = String(format: R.string.notifications.votedOnPost.localized(), self.actor, "your")
        } else if type == "FOLLOW" {
            string = String(format: R.string.notifications.startedFollowing.localized(), self.actor, "you")
        }
        let attributedString = NSMutableAttributedString(string: string)
        let actorRange = (string as NSString).range(of: self.actor)
        attributedString.addAttribute(.font, value: UIFont.customFont(with: 16, weight: .bold), range: actorRange)
        return attributedString
    }
}

struct NotificationInformationModel: Codable {
    
    let commentId: String?
    let descriptionText: String
    let postAuthor: String?
    let postPermlink: String?
    let commentedOnAutor: String?
    let commentedOnPermlink: String?
    let votedOnAuthor: String?
    let votedOnPermlink: String?
    let postThubmnails: [String]?
    
    enum CodingKeys: String, CodingKey {
        case commentId = "comment_id"
        case descriptionText = "description"
        case postAuthor = "post_author"
        case postPermlink = "post_permlink"
        case commentedOnAutor = "commented_on_author"
        case commentedOnPermlink = "commented_on_permlink"
        case votedOnAuthor = "voted_on_author"
        case votedOnPermlink = "voted_on_permlink"
        case postThubmnails = "post_thumbnail"
    }
}
