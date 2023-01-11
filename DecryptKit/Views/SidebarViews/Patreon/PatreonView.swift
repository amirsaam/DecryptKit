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
  @Binding var callbackState: String

  @ObservedResults(deUser.self) private var users
  @State private var newUser = deUser()

  @State private var patreon = Patreon()
  @State private var patreonUser: PatronOAuth?

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
          .onAppear {
            if isDeeplink {
              Task {
                await handleOAuthCallback(callbackCode)
                debugPrint(patreonUser ?? "getting tokens failed")
              }
            }
          }
          .onChange(of: isDeeplink) { boolean in
            if boolean {
              Task {
                await handleOAuthCallback(callbackCode)
                debugPrint(patreonUser ?? "getting tokens failed")
              }
            }
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
    isDeeplink = false
  }
}
