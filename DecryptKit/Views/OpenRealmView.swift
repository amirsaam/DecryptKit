//
//  OpenRealmView.swift
//  deCripple
//
//  Created by Amir Mohammadi on 9/18/1401 AP.
//

import Foundation
import SwiftUI
import RealmSwift
import DataCache

/// Called when login completes. Opens the realm asynchronously and navigates to the Items screen.
struct OpenRealmView: View {
  
  @AsyncOpen(appId: realmAppConfig.appId, timeout: 2000) var asyncOpen
  
  // Configuration used to open the realm.
  @Environment(\.realmConfiguration) private var config
  @EnvironmentObject var errorHandler: ErrorHandler
  
  // We must pass the user, so we can set the user.id when we create database objects
  @State var user: User
  @State private var userUUID = ""
  @State private var userIsBanned = false
  @State private var userEmailAddress = ""
  @State private var userTier = 0
  @State private var userPatreonToken = ""

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
               userUUID: $userUUID,
               userIsBanned: $userIsBanned,
               userEmailAddress: $userEmailAddress,
               userTier: $userTier,
               sourceData: $sourceData)
      .environment(\.realm, realm)
      .environmentObject(errorHandler)
      .task(priority: .high) {
        await doAddUser()
        await resolveSourceData()
        sourceData = try? cache.readCodable(forKey: "cachedSourceData")
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
    if user.customData["userUUID"] != nil {
      user.refreshCustomData { (result) in
        switch result {
        case .failure(let error):
          print("Failed to refresh custom data: \(error.localizedDescription)")
        case .success(let customData):
          print("Succesfully refreshed custom data")
          userUUID = customData["userUUID"] as! String
          userIsBanned = customData["userIsBanned"] as! Bool
          userEmailAddress = customData["userEmail"] as! String
          userTier = customData["userTier"] as! Int
          userPatreonToken = customData["userPatreonToken"] as! String
        }
      }
    } else {
      userEmailAddress = defaults.string(forKey: "Email") ?? ""
      debugPrint("Appending user.customData to Realm")
      newUser.userId = user.id
      newUser.userUUID = UIDevice.current.identifierForVendor?.uuidString ?? "Not Found"
      newUser.userIsBanned = false
      newUser.userEmail = userEmailAddress
      newUser.userTier = 0
      newUser.userPatreonToken = "Not Logged In to Patreon Yet"
      $users.append(newUser)
    }
  }
}
