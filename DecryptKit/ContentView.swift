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
  
  @ObservedObject var realmApp: RealmSwift.App
  
  var body: some View {
    if let user = realmApp.currentUser {
      OpenRealmView(user: user)
    } else {
      AccountingView()
    }
  }
}

struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    ContentView(realmApp: realmApp)
  }
}
