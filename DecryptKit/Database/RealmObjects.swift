//
//  RealmObjects.swift
//  deCripple
//
//  Created by Amir Mohammadi on 9/16/1401 AP.
//

import Foundation
import RealmSwift

class deReq: Object, ObjectKeyIdentifiable {
  @Persisted(primaryKey: true) var _id: ObjectId
  @Persisted var requestedId: String
//  @Persisted var requestedVersion: String
  @Persisted var requestersEmail: List<String>
//  @Persisted var requestedIsDecrypted: Bool
//  @Persisted var requestedDecryptedLink: String
}

class deStat: Object, ObjectKeyIdentifiable {
  @Persisted(primaryKey: true) var _id: ObjectId
  @Persisted var lookedId: String
  @Persisted var lookersEmail: List<String>
  @Persisted var lookersStat: Int
  @Persisted var lookStats: Int
}

class deUser: Object, ObjectKeyIdentifiable {
  @Persisted(primaryKey: true) var _id: ObjectId
  @Persisted var userId: String
  @Persisted var userUID: String
  @Persisted var userIsBanned: Bool
  @Persisted var userEmail: String
  @Persisted var userTier: Int
  @Persisted var userPAT: String
  @Persisted var userPRT: String
}
