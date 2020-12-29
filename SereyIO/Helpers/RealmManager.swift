//
//  RealmManager.swift
//  SereyIO
//
//  Created by Phanha Uy on 1/11/20.
//  Copyright © 2020 Phanha Uy. All rights reserved.
//

import Foundation
import RealmSwift

class RealmManager {
    
    static func deleteAll<T: Object>(_ type: T.Type, completion: @escaping () -> Void = {}) {
        // Delete an object with a transaction
        do {
            let realm = try Realm()
            let objToDelete = realm.objects(type)
            try? realm.write {
                realm.delete(objToDelete)
            }
            try? realm.commitWrite()
            completion()
        } catch let error as NSError {
            fatalError(error.localizedDescription)
        }
    }
    
    static func delete<T: Object>(_ type: T.Type, by predicate: @escaping () -> NSPredicate? = {return nil}, completion: @escaping ()-> Void = {}) {
        do {
            let realm = try Realm()
            
            var objToDelete = realm.objects(type)
            
            if let query = predicate() {
                objToDelete = objToDelete.filter(query)
            }
            
            if !objToDelete.isEmpty {
                try? realm.write {
                    realm.delete(objToDelete)
                }
                try? realm.commitWrite()
            }
            completion()
        } catch let error as NSError {
            fatalError(error.localizedDescription)
        }
    }
    
    static func delete(_ obj: Object) {
        do {
            let realm = try Realm()
            
            try? realm.write {
                realm.delete(obj)
            }
            try? realm.commitWrite()
        } catch let error as NSError {
            fatalError(error.localizedDescription)
        }
    }
    
    static func deleteAllObjects() {
        do {
            let realm = try Realm()
            try? realm.write {
                realm.deleteAll()
            }
        } catch let error as NSError {
            fatalError(error.localizedDescription)
        }
    }
}
