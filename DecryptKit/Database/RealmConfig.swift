//
//  RealmConfig.swift
//  deCripple
//
//  Created by Amir Mohammadi on 9/16/1401 AP.
//

import Foundation
import RealmSwift

struct AppConfig {
    var appId: String
    var baseUrl: String
}

func loadAppConfig() -> AppConfig {
    guard let path = Bundle.main.path(forResource: "Realm", ofType: "plist") else {
        fatalError("Could not load Realm.plist file!")
    }
    let data = NSData(contentsOfFile: path)! as Data
    let realmPropertyList = try! PropertyListSerialization.propertyList(from: data, format: nil) as! [String: Any]
    let appId = realmPropertyList["appId"]! as! String
    let baseUrl = realmPropertyList["baseUrl"]! as! String
    return AppConfig(appId: appId, baseUrl: baseUrl)
}
