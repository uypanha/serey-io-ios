//
//  DraftModel.swift
//  SereyIO
//
//  Created by Panha Uy on 12/22/20.
//  Copyright © 2020 Phanha Uy. All rights reserved.
//

import Foundation
import Realm
import RealmSwift

class DraftModel: Object {
    
    @objc dynamic var id: Int = 0
    @objc dynamic var postId: String? = nil
    @objc dynamic var title: String? = nil
    @objc dynamic var descriptionText: String? = nil
    @objc dynamic var shortDescription: String? = nil
    @objc dynamic var imageData: Data? = nil
    @objc dynamic var imageUrl: String? = nil
    
    override static func primaryKey() -> String? {
        return "id"
    }
}
