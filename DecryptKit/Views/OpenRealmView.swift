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
  @State private var updaterVM = UpdaterVM.shared
  @State private var userVM = UserVM.shared
  @State private var patreonVM = PatreonVM.shared
  @State private var showUpdateAlert = false
  @State private var noPlayCover = false
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
        .alert("An Update is Available!", isPresented: $showUpdateAlert) {
          Button("Download", role: .none) {
            if let url = URL(string: updaterVM.upstreamDownloadLink) {
              UIApplication.shared.open(url)
            }
          }
          Button("Dismiss", role: .cancel) {
            if updaterVM.upstreamIsCritical {
              exit(0)
            } else {
              return
            }
          }
        } message: {
          if updaterVM.upstreamIsCritical {
            Text("This is an necessary update that will break functionality of older versions, if you choose to not update, the app will be closed automatically.")
          } else {
            Text("A routine update that contains improvements and bug fixes, you can choose to update later.")
          }
        }
        .modifier(NoPlayCoverAlert(noPlayCover: $noPlayCover))
        .task(priority: .high) {
          if let url = URL(string: "x-apple-health://") {
            if UIApplication.shared.canOpenURL(url) {
              exit(0)
            }
          }
          await updaterVM.checkUpstream()
          if !updaterVM.appIsUpToDate {
            showUpdateAlert = true
          }
          await doCheckUser()
        }
      case .progress(let progress):
        ProgressView(progress)
          .padding()
      case .error(let error):
        RealmError(error: error)
          .padding()
          .foregroundColor(.red)
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
        semaphore.signal()
      case .success(let customData):
        Task { @MainActor in
          if customData["userId"] == nil {
            userVM.userUID = UIDevice.current.identifierForVendor?.uuidString ?? "UIDPlaceholder"
            debugPrint("Appending new custom data to Realm")
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
          } else {
            debugPrint("Succesfully retrieved custom data from Realm.")
            userVM.userUID = customData["userUID"] as! String
            userVM.userIsBanned = customData["userIsBanned"] as! Bool
            userVM.userEmail = customData["userEmail"] as! String
            userVM.userTier = customData["userTier"] as! Int
            userVM.userPAT = customData["userPAT"] as! String
            userVM.userPRT = customData["userPRT"] as! String
          }
          semaphore.signal()
        }
      }
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
      Task { @MainActor in
        print("Investigated user, they're good fellas!")
        patreonVM.patreonClient = await patreonVM.loadPatreonClientDetails()
        if let client = patreonVM.patreonClient {
          patreonVM.patreonAPI = PatreonAPI(
            clientID: client.clientID,
            clientSecret: client.clientSecret,
            creatorAccessToken: client.creatorAccessToken,
            creatorRefreshToken: client.creatorRefreshToken,
            redirectURI: client.redirectURI,
            campaignID: client.campaignID
          )
        }
        patreonVM.patreonCampaign = await patreonVM.patreonAPI.getDataForCampaign()
        if !userVM.userPAT.isEmpty && !patreonVM.patronTokensFetched {
          patreonVM.patreonOAuth = await patreonVM.patreonAPI.refreshOAuthTokens(userRefreshToken: userVM.userPRT)
          try! realm.write {
            currentUser[0].userPAT = patreonVM.patreonOAuth?.access_token ?? ""
            currentUser[0].userPRT = patreonVM.patreonOAuth?.refresh_token ?? ""
          }
          userVM.userPAT = patreonVM.patreonOAuth?.access_token ?? ""
          userVM.userPRT = patreonVM.patreonOAuth?.refresh_token ?? ""
          patreonVM.patronTokensFetched = true
          patreonVM.patronIdentity = await patreonVM.patreonAPI.getUserIdentity(userAccessToken: userVM.userPAT)
        }
        await resolveSourceData()
        try? await Task.sleep(nanoseconds: 5000000000)
        withAnimation {
          dataLoaded = true
        }
        print("AppData loaded, didn't it? Anyway, what you looking for in here mate?")
      }
    } else {
      print("A guilty user has been found!")
      try! realm.write {
        currentUser[0].userIsBanned = true
      }
      userVM.userIsBanned = true
    }
  }
}
