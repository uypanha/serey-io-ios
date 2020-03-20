//
//  File.swift
//  SereyIO
//
//  Created by Phanha Uy on 9/15/19.
//  Copyright © 2019 Phanha Uy. All rights reserved.
//

import Foundation
import RealmSwift

extension Realm {
    
    static func configureRealm(schemaVersion: UInt64) {
        
        let deleteRealmIfMigrationNeeded: Bool
        #if DEBUG
        deleteRealmIfMigrationNeeded = true
        #else
        deleteRealmIfMigrationNeeded = false
        #endif
        
        let encryptionConfig = Realm.Configuration(
            // Set the new schema version. This must be greater than the previously used
            // version (if you've never set a schema version before, the version is 0).
            schemaVersion: schemaVersion,
            
            // Set the block which will be called automatically when opening a Realm with
            // a schema version lower than the one set above
            migrationBlock: { migration, oldSchemaVersion in
                // We haven’t migrated anything yet, so oldSchemaVersion == 0
                if (oldSchemaVersion == 0) {
                }
        },
            
            deleteRealmIfMigrationNeeded: deleteRealmIfMigrationNeeded
        )
        
        // Tell Realm to use this new configuration object for the default Realm
        Realm.Configuration.defaultConfiguration = encryptionConfig
    }
    
    static func writeRealm(_ writeCompletion: @escaping (Realm) -> Void) {
        do {
            let realm = try Realm()
            try realm.write {
                writeCompletion(realm)
            }
        } catch let error as NSError {
            fatalError(error.localizedDescription)
        }
    }
}

extension Object {
    
    func queryAll<T: Object>(completion: @escaping (_ result: Results<T>) -> Void){
        do {
            print("Query with object type: \(T.self)")
            
            let realm = try Realm()
            let data = realm.objects(T.self)
            completion(data)
        } catch let error as NSError {
            fatalError(error.localizedDescription)
        }
        
    }
    
    func queryAll<T: Object>() -> Results<T> {
        do {
            let realm = try Realm()
            return realm.objects(T.self)
        } catch let error as NSError {
            fatalError(error.localizedDescription)
        }
    }
    
    func query<T: Object, KeyType>(byID id: KeyType, completion: @escaping (_ data: T?) -> Void){
        do {
            let realm = try Realm()
            let data = realm.object(ofType: T.self, forPrimaryKey: id)
            
            completion(data)
        } catch let error as NSError {
            fatalError(error.localizedDescription)
        }
    }
    
    func query<T: Object, KeyType>(byID id: KeyType) -> T? {
        do {
            let realm = try Realm()
            let data = realm.object(ofType: T.self, forPrimaryKey: id)
            
            return data
        } catch let error as NSError {
            fatalError(error.localizedDescription)
        }
    }
    
    func qeury<T: Object>(by predicate: NSPredicate) -> Results<T> {
        do {
            let realm = try Realm()
            let data = realm.objects(T.self).filter(predicate)
            return data
        } catch let error as NSError {
            fatalError(error.localizedDescription)
        }
    }
    
    func qeuryFirst<T: Object>() -> T? {
        do {
            let realm = try Realm()
            let data = realm.objects(T.self).first
            return data
        } catch let error as NSError {
            fatalError(error.localizedDescription)
        }
    }
    
    func qeuryFirst<T: Object>(by predicate: NSPredicate) -> T? {
        do {
            let realm = try Realm()
            let data = realm.objects(T.self).filter(predicate).first
            return data
        } catch let error as NSError {
            fatalError(error.localizedDescription)
        }
    }
    
    func save(){
        Realm.writeRealm { (realm) in
            realm.add(self, update: .all)
        }
    }
}

extension Array where Element: Object {
    
    func saveAll() {
        forEach { elment in
            elment.save()
        }
    }
}
