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
  @EnvironmentObject var errorHandler: ErrorHandler
  
  // We must pass the user, so we can set the user.id when we create database objects
  @State var user: User
  @State private var userUID = ""
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
               userUID: $userUID,
               userIsBanned: $userIsBanned,
               userEmailAddress: $userEmailAddress,
               userTier: $userTier,
               sourceData: $sourceData)
      .environment(\.realm, realm)
      .environmentObject(errorHandler)
      .task(priority: .high) { @MainActor in
        await doCheckUser()
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
  func doCheckUser() async {
    if ((user.customData["userId"]) == nil) {
      print(user.customData)
      userUID = uid
      userEmailAddress = defaults.string(forKey: "Email") ?? ""
      debugPrint("Appending user.customData to Realm")
      newUser.userId = user.id
      newUser.userUID = userUID
      newUser.userIsBanned = false
      newUser.userEmail = userEmailAddress
      newUser.userTier = 0
      newUser.userPatreonToken = "Not Logged In to Patreon Yet"
      $users.append(newUser)
    } else {
      user.refreshCustomData { (result) in
        switch result {
        case .failure(let error):
          print("Failed to refresh custom data: \(error.localizedDescription)")
        case .success(let customData):
          print("Succesfully refreshed custom data")
          userUID = customData["userUID"] as! String
          userIsBanned = customData["userIsBanned"] as! Bool
          userEmailAddress = customData["userEmail"] as! String
          userTier = customData["userTier"] as! Int
          userPatreonToken = customData["userPatreonToken"] as! String
          print(customData)
        }
      }
    }
    try? await Task.sleep(nanoseconds: 5000000000)
    if !userIsBanned {
      await checkForDuplicateUsers(userUID, userEmailAddress)
    }
  }
  func checkForDuplicateUsers(_ uid: String, _ email: String) async {
    let realm = users.realm!.thaw()
    let thawedUsers = users.thaw()!
    let duplicateUser = thawedUsers.where {
      !$0.userEmail.contains(userEmailAddress) && $0.userUID.contains(userUID)
    }
    let currentUser = thawedUsers.where {
      $0.userId.contains(user.id)
    }
    if duplicateUser.isEmpty {
      debugPrint("No duplicate user found")
      await resolveSourceData()
      sourceData = try? cache.readCodable(forKey: "cachedSourceData")
    } else {
      debugPrint("Duplicate user found, banning user")
      try! realm.write {
        currentUser[0].userIsBanned = true
      }
      userIsBanned = true
    }
  }
}
