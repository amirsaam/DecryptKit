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
  @Binding var showPatreon: Bool
  @Binding var callbackCode: String

  @EnvironmentObject var patreonVM: PatreonVM
  @ObservedResults(deUser.self) private var users
  @State private var newUser = deUser()

  @State private var patreonAPI = PatreonAPI.shared
  @State private var userVM = UserVM.shared

  var body: some View {
    GeometryReader { geo in
      ZStack {
        if showPatreon {
          SidebarBackground()
            .overlay {
              VStack(alignment: .leading, spacing: 25.0) {
                Text("Subscribe to our Patreon for accessing premium services!")
                  .font(.headline)
                  .multilineTextAlignment(.leading)
                PatreonCampaignDetails(patreonCampaign: $patreonVM.patreonCampaign,
                                       patreonTiers: $patreonVM.campaignTiers,
                                       patreonBenefits: $patreonVM.campaignBenefits)
                Button {
                  patreonAPI.doOAuth()
                } label: {
                  Label(userVM.userPAT.isEmpty
                        ? "Link your Patreon"
                        : patreonVM.patronIdentity == nil
                        ? "Loading..."
                        : "Signed-In as \(patreonVM.patronIdentity?.data.attributes.full_name ?? "")",
                        systemImage: !userVM.userPAT.isEmpty && patreonVM.patronIdentity == nil
                        ? "circle.dotted"
                        : "link")
                  .font(.caption2)
                  .frame(maxWidth: .infinity)
                }
                .softButtonStyle(
                  RoundedRectangle(cornerRadius: 7.5),
                  padding: 10,
                  pressedEffect: .flat
                )
                .padding(.top)
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
          debugPrint(patreonVM.patreonOAuth ?? "getting tokens failed")
        } else if !userVM.userPAT.isEmpty && !patreonVM.tokensFetched {
          await handleRefreshToken(userVM.userPRT)
          debugPrint(patreonVM.patreonOAuth ?? "refreshing tokens failed")
        }
      }
    }
    .onChange(of: isDeeplink) { boolean in
      if boolean {
        Task {
          await handleOAuthCallback(callbackCode)
          debugPrint(patreonVM.patreonOAuth ?? "getting tokens failed")
        }
      }
    }
    .onChange(of: patreonVM.tokensFetched) { boolean in
      Task {
        if boolean {
          patreonVM.patronIdentity = await patreonAPI.getUserIdentity(userVM.userPAT)
        }
      }
    }
  }
  func handleOAuthCallback(_ callbackCode: String) async {
    patreonVM.patreonOAuth = await patreonAPI.getOAuthTokens(callbackCode)
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
    patreonVM.patreonOAuth = await patreonAPI.refreshOAuthTokens(refreshToken)
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
}
