//
//  RealmObjects.swift
//  DecryptKit
//
//  Created by Amir Mohammadi on 9/16/1401 AP.
//

import Foundation
import RealmSwift

class Users: Object, ObjectKeyIdentifiable {
  @Persisted(primaryKey: true) var _id: ObjectId
  @Persisted var useremails: List<String>
  @Persisted var userCount: Int
}

class LookedupStats: Object, ObjectKeyIdentifiable {
  @Persisted(primaryKey: true) var _id: ObjectId
  @Persisted var bundleID: String
  @Persisted var emails: List<String>
  @Persisted var lookStats: Int
}
