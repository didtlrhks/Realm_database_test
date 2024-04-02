//
//  Recording.swift
//  Realm_database_test
//
//  Created by 양시관 on 4/2/24.
//

import Foundation
import Realm
import RealmSwift

class Recording: Object {
    @objc dynamic var id = UUID().uuidString
    @objc dynamic var filePath = ""
    @objc dynamic var recordedDate = Date()
    
    override static func primaryKey() -> String? {
        return "id"
    }
}
