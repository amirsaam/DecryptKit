//
//  OpenRealmView.swift
//  deCripple
//
//  Created by Amir Mohammadi on 9/18/1401 AP.
//

import SwiftUI
import RealmSwift
import Semaphore
import PatreonAPI

// MARK: - View Struct
/// Called when login completes. Opens the realm asynchronously and navigates to the Items screen.
struct OpenRealmView: View {

  @AsyncOpen(appId: realmAppConfig.appId, timeout: 15000) var asyncOpen

  @EnvironmentObject var errorHandler: ErrorHandler
  // Configuration used to open the realm.
  @Environment(\.realmConfiguration) private var config

  // We must pass the user, so we can set the user.id when we create database objects
  @State var user: User
  @State private var userVM = UserVM.shared
  @State private var dataLoaded = false

  @ObservedResults(deUser.self) private var users
  @State private var newUser = deUser()

  // MARK: - View Body
  var body: some View {
    ZStack {
      mainColor
        .ignoresSafeArea(.all)
      switch asyncOpen {
      case .connecting:
        BrandProgress(logoSize: 50,
                      progressText: "Connecting...")
        .padding()
      case .waitingForUser:
        BrandProgress(logoSize: 50,
                      progressText: "Waiting for user to log in...")
        .padding()
      case .open(let realm):
        MainView(user: $user,
                 dataLoaded: $dataLoaded)
        .environment(\.realm, realm)
        .environmentObject(errorHandler)
        .task(priority: .high) {
          await doCheckUser()
          PatreonVM.shared.patreonCampaign = await patreonAPI.getDataForCampaign()
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
          userVM.userUID = uid
          debugPrint("Appending new custom data to Realm")
          Task { @MainActor in
            let email = defaults.string(forKey: "Email") ?? ""
            newUser.userId = user.id
            newUser.userUID = userVM.userUID
            newUser.userIsBanned = false
            newUser.userEmail = email
            newUser.userTier = 0
            newUser.userPAT = ""
            newUser.userPRT = ""
            $users.append(newUser)
            userVM.userEmail = email
          }
        } else {
          debugPrint("Succesfully retrieved custom data from Realm")
          userVM.userUID = customData["userUID"] as! String
          userVM.userIsBanned = customData["userIsBanned"] as! Bool
          userVM.userEmail = customData["userEmail"] as! String
          userVM.userTier = customData["userTier"] as! Int
          userVM.userPAT = customData["userPAT"] as! String
          userVM.userPRT = customData["userPRT"] as! String
          debugPrint(customData)
        }
      }
      semaphore.signal()
    }
    await semaphore.wait()
    if !userVM.userIsBanned {
      checkForDuplicateUsers(userVM.userUID)
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
        withAnimation {
          dataLoaded = true
        }
      }
    } else {
      debugPrint("Duplicate user found, banning user")
      try! realm.write {
        currentUser[0].userIsBanned = true
      }
      userVM.userIsBanned = true
    }
  }
}
