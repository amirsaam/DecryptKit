//
//  deCrippleApp.swift
//  deCripple
//
//  Created by Amir Mohammadi on 9/3/1401 AP.
//

import SwiftUI
import Neumorphic
import RealmSwift
import DataCache

let mainColor = Color.Neumorphic.main
let secondaryColor = Color.Neumorphic.secondary
let defaults = UserDefaults.standard
let cache = DataCache.instance
let playcoverURL = URL(string: "playcover:source?action=add&url=https://amrsm.ir/decrypted.json")

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
