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

let playcoverPublicURL = URL(string: SourcesURLs.playCoverHandler.rawValue + SourcesURLs.free.rawValue)
let playcoverVIPURL = URL(string: SourcesURLs.playCoverHandler.rawValue + SourcesURLs.vip.rawValue)

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
