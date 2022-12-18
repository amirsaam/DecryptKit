//
//  OpenRealmView.swift
//  deCripple
//
//  Created by Amir Mohammadi on 9/18/1401 AP.
//

import SwiftUI
import RealmSwift

/// Called when login completes. Opens the realm asynchronously and navigates to the Items screen.
struct OpenRealmView: View {
  
  @AsyncOpen(appId: realmAppConfig.appId, timeout: 2000) var asyncOpen
  
  // Configuration used to open the realm.
  @Environment(\.realmConfiguration) private var config
  
  // We must pass the user, so we can set the user.id when we create database objects
  @State var user: User
  
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
      MainView(user: user)
      .environment(\.realm, realm)
      .task(priority: .background) {
        await resolveSourceData()
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
}
