//
//  RealmConfig.swift
//  deCripple
//
//  Created by Amir Mohammadi on 9/16/1401 AP.
//

import Foundation
import RealmSwift

/// Store the Realm app details to use when instantiating the app and
/// when using the `@AsyncOpen` property wrapper to open the realm.
struct RealmAppConfig {
  var appId: String
  var baseUrl: String
}

/// Read the Realm.plist file and store the app ID and baseUrl to use elsewhere.
func loadRealmAppConfig() -> RealmAppConfig {
  guard let path = Bundle.main.path(forResource: "atlasConfig", ofType: "plist") else {
    // Any errors here indicate that the Realm.plist file has not been formatted properly.
    fatalError("Could not load Realm.plist file!")
  }
  let data = NSData(contentsOfFile: path)! as Data
  let realmPropertyList = try! PropertyListSerialization.propertyList(from: data, format: nil) as! [String: Any]
  let appId = realmPropertyList["appId"]! as! String
  let baseUrl = realmPropertyList["baseUrl"]! as! String
  setenv("REALM_DISABLE_METADATA_ENCRYPTION", "1", 1)
  return RealmAppConfig(appId: appId, baseUrl: baseUrl)
}
