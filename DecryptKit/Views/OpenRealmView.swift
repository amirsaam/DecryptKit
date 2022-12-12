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

  @AsyncOpen(appId: theAppConfig.appId, timeout: 2000) var asyncOpen

  // We must pass the user, so we can set the user.id when we create database objects
  @State var user: User
  
  var body: some View {
    switch asyncOpen {
    case .connecting:
      ZStack {
        mainColor
          .ignoresSafeArea(.all)
        ProgressView()
      }
    case .waitingForUser:
      ZStack {
        mainColor
          .ignoresSafeArea(.all)
        ProgressView("Waiting for user to log in...")
      }
    case .open(let realm):
      MainView(user: user)
        .environment(\.realm, realm)
    case .progress(let progress):
      ZStack {
        mainColor
          .ignoresSafeArea(.all)
        ProgressView(progress)
      }
    case .error(let error):
      ZStack {
        mainColor
          .ignoresSafeArea(.all)
        RealmError(error: error)
      }
    }
  }
}
