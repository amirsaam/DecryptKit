//
//  OpenRealmView.swift
//  deCripple
//
//  Created by Amir Mohammadi on 9/18/1401 AP.
//

import SwiftUI
import RealmSwift
import DataCache
import Semaphore

// MARK: - View Struct
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
  @State private var userPAT = ""
  @State private var userPRT = ""

  @ObservedResults(deUser.self) private var users
  @State private var newUser = deUser()

  @State private var sourceData: [deCrippleSource]?

  // MARK: - View Body
  var body: some View {
    ZStack {
      mainColor
        .ignoresSafeArea(.all)
      switch asyncOpen {
      case .connecting:
        ProgressView()
          .padding()
      case .waitingForUser:
        ProgressView("Waiting for user to log in...")
          .padding()
      case .open(let realm):
        MainView(user: user,
                 userUID: $userUID,
                 userIsBanned: $userIsBanned,
                 userEmailAddress: $userEmailAddress,
                 userTier: $userTier,
                 userPAT: $userPAT,
                 userPRT: $userPRT,
                 sourceData: $sourceData)
        .environment(\.realm, realm)
        .environmentObject(errorHandler)
        .task(priority: .high) { @MainActor in
          await doCheckUser()
        }
      case .progress(let progress):
        ProgressView(progress)
          .padding()
      case .error(let error):
        RealmError(error: error)
          .padding()
      }
    }
  }
  // MARK: - Get/Send UserData to Realm
  func doCheckUser() async {
    let semaphore = AsyncSemaphore(value: 0)
    user.refreshCustomData { (result) in
      switch result {
      case .failure(let error):
        debugPrint("Failed to refresh custom data: \(error.localizedDescription)")
      case .success(let customData):
        if customData["userId"] == nil {
          userUID = uid
          userEmailAddress = defaults.string(forKey: "Email") ?? ""
          debugPrint("Appending new custom data to Realm")
          Task { @MainActor in
            newUser.userId = user.id
            newUser.userUID = userUID
            newUser.userIsBanned = false
            newUser.userEmail = userEmailAddress
            newUser.userTier = 0
            newUser.userPAT = ""
            newUser.userPRT = ""
            $users.append(newUser)
          }
        } else {
          debugPrint("Succesfully retrieved custom data from Realm")
          userUID = customData["userUID"] as! String
          userIsBanned = customData["userIsBanned"] as! Bool
          userEmailAddress = customData["userEmail"] as! String
          userTier = customData["userTier"] as! Int
          userPAT = customData["userPAT"] as! String
          userPRT = customData["userPRT"] as! String
          debugPrint(customData)
        }
      }
      semaphore.signal()
    }
    await semaphore.wait()
    if !userIsBanned {
      checkForDuplicateUsers(userUID)
    }
  }
  // MARK: - Check for Possible Ban
  func checkForDuplicateUsers(_ uid: String) {
    let realm = users.realm!.thaw()
    let thawedUsers = users.thaw()!
    let duplicateUser = thawedUsers.where {
      !$0.userId.contains(user.id) && $0.userUID.contains(uid)
    }
    let currentUser = thawedUsers.where {
      $0.userId.contains(user.id)
    }
    if duplicateUser.isEmpty {
      debugPrint("No duplicate user found")
      Task { @MainActor in
        await resolveSourceData()
      }
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
