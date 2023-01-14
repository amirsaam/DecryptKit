//
//  PatreonView.swift
//  deCripple
//
//  Created by Amir Mohammadi on 10/18/1401 AP.
//

import SwiftUI
import Neumorphic
import RealmSwift

struct PatreonView: View {

  @State var user: User
  @Binding var isDeeplink: Bool
  @Binding var tokensFetched: Bool
  @Binding var showPatreon: Bool
  @Binding var callbackCode: String
  @Binding var userPAT: String
  @Binding var userPRT: String

  @ObservedResults(deUser.self) private var users
  @State private var newUser = deUser()

  @State private var patreon = Patreon.shared
  @State private var patreonOAuth: PatronOAuth?

  var body: some View {
    ZStack {
      if showPatreon {
        SidebarBackground()
          .overlay {
            VStack(alignment: .leading, spacing: 25.0) {
              Text("Click to OAuth")
                .onTapGesture {
                  patreon.doOAuth()
                }
              Button {
                withAnimation(.spring()) {
                  showPatreon = false
                }
              } label: {
                Image(systemName: "chevron.compact.right")
              }
              .softButtonStyle(
                Circle(),
                pressedEffect: .flat
              )
            }
          }
      }
    }
    .onAppear {
      Task {
        if isDeeplink {
          await handleOAuthCallback(callbackCode)
          debugPrint(patreonOAuth ?? "getting tokens failed")
        } else if !userPRT.isEmpty && !tokensFetched {
          await handleRefreshToken(userPRT)
          debugPrint(patreonOAuth ?? "refreshing tokens failed")
        }
      }
    }
    .onChange(of: isDeeplink) { boolean in
      if boolean {
        Task {
          await handleOAuthCallback(callbackCode)
          debugPrint(patreonOAuth ?? "getting tokens failed")
        }
      }
    }
  }
  func handleOAuthCallback(_ callbackCode: String) async {
    patreonOAuth = await patreon.getOAuthTokens(callbackCode)
    let realm = users.realm!.thaw()
    let thawedUsers = users.thaw()!
    let currentUser = thawedUsers.where {
      $0.userId.contains(user.id)
    }
    try! realm.write {
      currentUser[0].userPAT = patreonOAuth?.access_token ?? ""
      currentUser[0].userPRT = patreonOAuth?.refresh_token ?? ""
    }
    userPAT = patreonOAuth?.access_token ?? ""
    userPRT = patreonOAuth?.refresh_token ?? ""
    isDeeplink = false
    tokensFetched = true
  }
  func handleRefreshToken(_ refreshToken: String) async {
    patreonOAuth = await patreon.refreshOAuthTokens(refreshToken)
    let realm = users.realm!.thaw()
    let thawedUsers = users.thaw()!
    let currentUser = thawedUsers.where {
      $0.userId.contains(user.id)
    }
    try! realm.write {
      currentUser[0].userPAT = patreonOAuth?.access_token ?? ""
      currentUser[0].userPRT = patreonOAuth?.refresh_token ?? ""
    }
    userPAT = patreonOAuth?.access_token ?? ""
    userPRT = patreonOAuth?.refresh_token ?? ""
    tokensFetched = true
  }
}
