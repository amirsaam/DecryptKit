//
//  PatreonView.swift
//  deCripple
//
//  Created by Amir Mohammadi on 10/18/1401 AP.
//

import SwiftUI
import Neumorphic
import RealmSwift
import PatreonAPI

struct PatreonView: View {

  @State var user: User
  @Binding var isDeeplink: Bool
  @Binding var showPatreon: Bool
  @Binding var callbackCode: String

  @EnvironmentObject var patreonVM: PatreonVM
  @ObservedResults(deUser.self) private var users
  @State private var newUser = deUser()

  @State private var userVM = UserVM.shared
  @State private var presentPatreonUnlink = false

  var body: some View {
    GeometryReader { geo in
      ZStack {
        if showPatreon {
          SidebarBackground()
            .overlay {
              VStack(alignment: .leading, spacing: 25.0) {
                Text("Subscribe to our Patreon for accessing premium services!")
                  .font(.headline)
                PatreonCampaignDetails(patreonCampaign: $patreonVM.patreonCampaign,
                                       patreonTiers: $patreonVM.campaignTiers,
                                       patreonBenefits: $patreonVM.campaignBenefits)
                Button {
                  if userVM.userPAT.isEmpty {
                    patreonAPI.doOAuth()
                  } else if !userVM.userPAT.isEmpty && patreonVM.patronIdentity == nil {
                    
                  } else {
                    presentPatreonUnlink = true
                  }
                } label: {
                  Group {
                    if userVM.userPAT.isEmpty {
                      Label("Link your Patreon", systemImage: "link")
                    } else if !userVM.userPAT.isEmpty && patreonVM.patronIdentity == nil {
                      Label("Loading...", systemImage: "circle.dotted")
                    } else {
                      Label("Unlink Patreon (\(patreonVM.patronIdentity?.data.attributes.full_name ?? ""))", systemImage: "link")
                    }
                  }
                  .font(.caption2.bold())
                  .frame(maxWidth: .infinity)
                }
                .softButtonStyle(
                  RoundedRectangle(cornerRadius: 7.5),
                  padding: 10,
                  pressedEffect: .flat
                )
                .padding(.top)
                .alert("Are you sure?", isPresented: $presentPatreonUnlink) {
                  Button("Yes, Unlink!", role: .none) {
                    Task {
                      await handlePatreonUnlink()
                    }
                  }
                  Button("Cancel", role: .cancel) { return }
                } message: {
                  Text("Unlinking your Patreon account from DecryptKit removes your access to the benefits you own but will not unsubscribe you from our Patreon.")
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
              .frame(width: geo.size.width * (8.25/10))
            }
        }
      }
    }
    .onAppear {
      Task {
        if isDeeplink {
          await handleOAuthCallback(callbackCode)
        } else if !userVM.userPAT.isEmpty && !patreonVM.tokensFetched {
          await handleRefreshToken(userVM.userPRT)
        }
      }
    }
    .onChange(of: isDeeplink) { boolean in
      if boolean {
        Task {
          await handleOAuthCallback(callbackCode)
        }
      }
    }
    .onChange(of: patreonVM.tokensFetched) { boolean in
      Task {
        if boolean {
          patreonVM.patronIdentity = await patreonAPI.getUserIdentity(userAccessToken: userVM.userPAT)
        }
      }
    }
  }

  func handleOAuthCallback(_ callbackCode: String) async {
    patreonVM.patreonOAuth = await patreonAPI.getOAuthTokens(callbackCode: callbackCode)
    let realm = users.realm!.thaw()
    let thawedUsers = users.thaw()!
    let currentUser = thawedUsers.where {
      $0.userId.contains(user.id)
    }
    try! realm.write {
      currentUser[0].userPAT = patreonVM.patreonOAuth?.access_token ?? ""
      currentUser[0].userPRT = patreonVM.patreonOAuth?.refresh_token ?? ""
    }
    userVM.userPAT = patreonVM.patreonOAuth?.access_token ?? ""
    userVM.userPRT = patreonVM.patreonOAuth?.refresh_token ?? ""
    isDeeplink = false
    patreonVM.tokensFetched = true
  }

  func handleRefreshToken(_ refreshToken: String) async {
    patreonVM.patreonOAuth = await patreonAPI.refreshOAuthTokens(userRefreshToken: refreshToken)
    let realm = users.realm!.thaw()
    let thawedUsers = users.thaw()!
    let currentUser = thawedUsers.where {
      $0.userId.contains(user.id)
    }
    try! realm.write {
      currentUser[0].userPAT = patreonVM.patreonOAuth?.access_token ?? ""
      currentUser[0].userPRT = patreonVM.patreonOAuth?.refresh_token ?? ""
    }
    userVM.userPAT = patreonVM.patreonOAuth?.access_token ?? ""
    userVM.userPRT = patreonVM.patreonOAuth?.refresh_token ?? ""
    patreonVM.tokensFetched = true
  }

  func handlePatreonUnlink() async {
    let realm = users.realm!.thaw()
    let thawedUsers = users.thaw()!
    let currentUser = thawedUsers.where {
      $0.userId.contains(user.id)
    }
    try! realm.write {
      currentUser[0].userPAT = ""
      currentUser[0].userPRT = ""
      currentUser[0].userTier = 0
    }
    userVM.userPAT = ""
    userVM.userPRT = ""
  }
}
