//
//  OpenRealmView.swift
//  deCripple
//
//  Created by Amir Mohammadi on 9/18/1401 AP.
//

import SwiftUI
import RealmSwift
import DataCache

/// Called when login completes. Opens the realm asynchronously and navigates to the Items screen.
struct OpenRealmView: View {
  
  @AsyncOpen(appId: realmAppConfig.appId, timeout: 2000) var asyncOpen
  
  // Configuration used to open the realm.
  @Environment(\.realmConfiguration) private var config
  
  // We must pass the user, so we can set the user.id when we create database objects
  @State var user: User
  @State private var userEmailAddress: String = ""

  @ObservedResults(deUser.self) private var users
  @State private var newUser = deUser()
  
  @State private var sourceData: [deCrippleSource]?

  var body: some View {
    switch asyncOpen {
    case .connecting:
      ZStack {
        mainColor
          .ignoresSafeArea(.all)
        ProgressView()
          .padding()
      }
    case .waitingForUser:
      ZStack {
        mainColor
          .ignoresSafeArea(.all)
        ProgressView("Waiting for user to log in...")
          .padding()
      }
    case .open(let realm):
      MainView(user: user,
               userEmailAddress: $userEmailAddress,
               sourceData: $sourceData)
      .environment(\.realm, realm)
      .task(priority: .high) {
        await doAddUser()
        await resolveSourceData()
        sourceData = try? DataCache.instance.readCodable(forKey: "cachedSourceData")
      }
    case .progress(let progress):
      ZStack {
        mainColor
          .ignoresSafeArea(.all)
        ProgressView(progress)
          .padding()
      }
    case .error(let error):
      ZStack {
        mainColor
          .ignoresSafeArea(.all)
        RealmError(error: error)
          .padding()
      }
    }
  }
  func doAddUser() async {
    if user.customData["userEmail"] != nil {
      user.refreshCustomData { (result) in
        switch result {
        case .failure(let error):
          print("Failed to refresh custom data: \(error.localizedDescription)")
        case .success(let customData):
          debugPrint(user.customData["userEmail"]!!)
          userEmailAddress = customData["userEmail"] as! String
        }
      }
    } else {
      debugPrint("Appending user.customData to Realm")
      userEmailAddress = defaults.string(forKey: "Email") ?? ""
      newUser.userId = user.id
      newUser.userEmail = userEmailAddress
      $users.append(newUser)
    }
  }
}
