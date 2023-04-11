//
//  deCrippleApp.swift
//  deCripple
//
//  Created by Amir Mohammadi on 9/3/1401 AP.
//

import Foundation
import SwiftUI
import Neumorphic
import RealmSwift
import DataCache
import PatreonAPI

let mainColor = Color.Neumorphic.main
let secondaryColor = Color.Neumorphic.secondary

let defaults = UserDefaults.standard
let cache = DataCache.instance
let patreonAPI = PatreonAPI(
  clientID: "MKzRZxagIOea-ceFt_54sjf9yyA2TzTHln9LiUoybU8ZRg7ljS4KE9HrBPa9i6aA",
  clientSecret: "4kTPw037oTE6D9zGHDwBgxqljtd70UkLBXAA25lIk83ZRbrlQjNr3sN8-TFa8dI6",
  creatorAccessToken: "f28mTaS7tddZRu3wNHDEJjbqemg_2gS2XLbgB8RoOxo",
  creatorRefreshToken: "6YQIsyM1SYgD0NQfV_sPXi15VnaqDqvdfssX1tKacJs",
  redirectURI: "https://decryptkit.xyz/patreon/6NvbE37T33cKTmpu1DkAtvuEK4XdWzF",
  campaignID: "9760149"
)

let playcoverPublicURL = URL(string: "apple-magnifier://source?action=add&url=https://repo.decryptkit.xyz/decrypted.json")
let playcoverVIPURL = URL(string: "apple-magnifier://source?action=add&url=https://repo.decryptkit.xyz/vip.json")

/// Load app config details from a Realm.plist we generated
let realmAppConfig = loadRealmAppConfig()
let appConfiguration = AppConfiguration(
  baseURL: realmAppConfig.baseUrl,
  transport: nil,
  localAppName: nil,
  localAppVersion: nil,
  defaultRequestTimeoutMS: 30000
)
let realmApp = App(id: realmAppConfig.appId, configuration: appConfiguration)

@main
struct deCrippleApp: SwiftUI.App {

  @StateObject var errorHandler = ErrorHandler(app: realmApp)

  var body: some Scene {
    WindowGroup {
      ContentView(app: realmApp)
        .accentColor(.red)
        .environmentObject(errorHandler)
        .alert("A Wild Error Appeared!", isPresented: .constant(errorHandler.error != nil)) {
          Button("OK", role: .cancel) {
            errorHandler.error = nil
          }
        } message: {
          Text(errorHandler.error?.localizedDescription ?? "")
        }
    }
  }
}

final class ErrorHandler: ObservableObject {
  @Published var error: Swift.Error?

  init(app: RealmSwift.App) {
    // Sync Manager listens for sync errors.
    app.syncManager.errorHandler = { syncError, syncSession in
      self.error = syncError
    }
  }
}
