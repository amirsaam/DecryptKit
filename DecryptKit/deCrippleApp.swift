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

let uid = UIDevice.current.identifierForVendor?.uuidString ?? "UID not Found"
let mainColor = Color.Neumorphic.main
let secondaryColor = Color.Neumorphic.secondary
let defaults = UserDefaults.standard
let cache = DataCache.instance
let playcoverURL = URL(string: "playcover:source?action=add&url=https://amrsm.ir/decrypted.json")

struct PatreonClient {
  public static let shared = PatreonClient()
  
  let clientID = "MKzRZxagIOea-ceFt_54sjf9yyA2TzTHln9LiUoybU8ZRg7ljS4KE9HrBPa9i6aA"
  let clientSecret = "4kTPw037oTE6D9zGHDwBgxqljtd70UkLBXAA25lIk83ZRbrlQjNr3sN8-TFa8dI6"
  let creatorAccessToken = "mfN-03GqFy6AiE7Jzq-I7CEdWuXfHMg_2VlLO0kcMgE"
  let creatorRefreshToken = "rnz8ny-qw8kdVM3bFyL27fssb1jRqta11WARXfPUm_Q"
  let redirectURI = "https://decryptkit.xyz/patreon/6NvbE37T33cKTmpu1DkAtvuEK4XdWzF"
  let campaignID = "9760149"
}

let patreonAPI = PatreonAPI(clientID: PatreonClient.shared.clientID,
                            clientSecret: PatreonClient.shared.clientSecret,
                            creatorAccessToken: PatreonClient.shared.creatorAccessToken,
                            creatorRefreshToken: PatreonClient.shared.creatorRefreshToken,
                            redirectURI: PatreonClient.shared.redirectURI,
                            campaignID: PatreonClient.shared.campaignID)

/// Load app config details from a Realm.plist we generated
let realmAppConfig = loadRealmAppConfig()
let appConfiguration = AppConfiguration(
  baseURL: realmAppConfig.baseUrl,
  transport: nil,
  localAppName: nil,
  localAppVersion: nil,
  defaultRequestTimeoutMS: 30000
)
@MainActor
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
