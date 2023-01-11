//
//  PatreonView.swift
//  DecryptKit
//
//  Created by Amir Mohammadi on 10/18/1401 AP.
//

import SwiftUI
import Neumorphic
import RealmSwift

struct PatreonView: View {

  @State var user: User
  @Binding var isDeeplink: Bool
  @Binding var showPatreon: Bool
  @Binding var callbackCode: String
  @Binding var userPAT: String
  @Binding var userPRT: String

  @ObservedResults(deUser.self) private var users
  @State private var newUser = deUser()

  @State private var patreon = Patreon()
  @State private var patreonUser: PatronOAuth?
  @State private var tokensFetched = false

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
          debugPrint(patreonUser ?? "getting tokens failed")
          tokensFetched = true
        } else if !userPRT.isEmpty && !tokensFetched {
          await handleRefreshToken(userPRT)
          debugPrint(patreonUser ?? "refreshing tokens failed")
          tokensFetched = true
        }
      }
    }
    .onChange(of: isDeeplink) { boolean in
      if boolean {
        Task {
          await handleOAuthCallback(callbackCode)
          debugPrint(patreonUser ?? "getting tokens failed")
          tokensFetched = true
        }
      }
    }
  }
  func handleOAuthCallback(_ callbackCode: String) async {
    patreonUser = await patreon.getOAuthTokens(callbackCode)
    let realm = users.realm!.thaw()
    let thawedUsers = users.thaw()!
    let currentUser = thawedUsers.where {
      $0.userId.contains(user.id)
    }
    try! realm.write {
      currentUser[0].userPAT = patreonUser?.access_token ?? ""
      currentUser[0].userPRT = patreonUser?.refresh_token ?? ""
    }
    userPAT = patreonUser?.access_token ?? ""
    userPRT = patreonUser?.refresh_token ?? ""
    isDeeplink = false
  }
  func handleRefreshToken(_ refreshToken: String) async {
    patreonUser = await patreon.refreshOAuthTokens(refreshToken)
    let realm = users.realm!.thaw()
    let thawedUsers = users.thaw()!
    let currentUser = thawedUsers.where {
      $0.userId.contains(user.id)
    }
    try! realm.write {
      currentUser[0].userPAT = patreonUser?.access_token ?? ""
      currentUser[0].userPRT = patreonUser?.refresh_token ?? ""
    }
    userPAT = patreonUser?.access_token ?? ""
    userPRT = patreonUser?.refresh_token ?? ""
  }
}
