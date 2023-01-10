//
//  ContentView.swift
//  deCripple
//
//  Created by Amir Mohammadi on 8/29/1401 AP.
//

import SwiftUI
import Neumorphic
import RealmSwift

struct ContentView: View {
  
  @ObservedObject var app: RealmSwift.App
  @EnvironmentObject var errorHandler: ErrorHandler
  
  var body: some View {
    if let user = app.currentUser {
      let config = user.flexibleSyncConfiguration(
        clientResetMode: .recoverOrDiscardUnsyncedChanges(),
        initialSubscriptions: { subs in
          let reqsSubscriptionExists = subs.first(named: "requestedId")
          let looksSubscriptionExists = subs.first(named: "lookedId")
          let usersSubscriptionExists = subs.first(named: "userId")
          if (reqsSubscriptionExists != nil) && (looksSubscriptionExists != nil) && (usersSubscriptionExists != nil) {
            return
          } else {
            subs.append(QuerySubscription<deReq>(name: "requestedId"))
            subs.append(QuerySubscription<deStat>(name: "lookedId"))
            subs.append(QuerySubscription<deUser>(name: "userId"))
          }
        })
      OpenRealmView(user: user)
        .environment(\.realmConfiguration, config)
        .environmentObject(errorHandler)
    } else {
      AccountingView()
    }
  }
}

struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    ContentView(app: realmApp)
  }
}
