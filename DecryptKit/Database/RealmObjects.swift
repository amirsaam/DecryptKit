//
//  RealmObjects.swift
//  DecryptKit
//
//  Created by Amir Mohammadi on 9/16/1401 AP.
//

import Foundation
import RealmSwift

class deReq: Object, ObjectKeyIdentifiable {
  @Persisted(primaryKey: true) var _id: ObjectId
  @Persisted var requestedId: String
  @Persisted var requestersEmail: List<String>
}

class deStat: Object, ObjectKeyIdentifiable {
  @Persisted(primaryKey: true) var _id: ObjectId
  @Persisted var lookedId: String
  @Persisted var lookersEmail: List<String>
  @Persisted var lookStats: Int
}

class deUser: Object, ObjectKeyIdentifiable {
  @Persisted(primaryKey: true) var _id: ObjectId
  @Persisted var userId: String
  @Persisted var userEmail: String
}
