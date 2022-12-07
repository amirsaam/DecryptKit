//
//  deCrippleApp.swift
//  deCripple
//
//  Created by Amir Mohammadi on 9/3/1401 AP.
//

import SwiftUI
import Neumorphic
import RealmSwift

let mainColor = Color.Neumorphic.main
let secondaryColor = Color.Neumorphic.secondary
let defaults = UserDefaults.standard

let theAppConfig = loadAppConfig()
let realmApp = App (
  id: theAppConfig.appId,
  configuration: AppConfiguration(
    baseURL: theAppConfig.baseUrl,
    transport: nil,
    localAppName: nil,
    localAppVersion: nil
  )
)

@main
struct deCrippleApp: SwiftUI.App {
  var body: some Scene {
    WindowGroup {
      ContentView(app: realmApp)
        .frame(width: 1400)
        .onDisappear {
          exit(0)
        }
    }
  }
}
