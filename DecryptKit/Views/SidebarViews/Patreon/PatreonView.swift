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
  @EnvironmentObject var userVM: UserVM

  @ObservedResults(deUser.self) private var users
  @State private var newUser = deUser()

  @State private var noPlayCover = false
  @State private var presentPatreonUnlink = false

  var body: some View {
    GeometryReader { geo in
      ZStack {
        if showPatreon {
          SidebarBackground()
            .overlay {
              VStack(alignment: .leading, spacing: 20) {
                Text("Join our Patreon for access to premium services!")
                  .font(.headline)
                if patreonVM.patreonCampaign == nil {
                  HStack {
                    Spacer()
                    ProgressView()
                      .controlSize(.large)
                    Spacer()
                  }
                } else {
                  PatreonCampaignDetails(user: user,
                                         patreonCampaign: $patreonVM.patreonCampaign,
                                         patreonTiers: $patreonVM.campaignTiers,
                                         patreonBenefits: $patreonVM.campaignBenefits,
                                         patronMembership: $patreonVM.patronMembership)
                }
                if !patreonVM.userIsPatron && userVM.userTier < 4 {
                  Text("You are using DecryptKit's FREE services.")
                    .font(.caption.italic())
                    .padding(.top)
                } else if userVM.userTier > 1 {
                  Button {
                    if let url = playcoverVIPURL {
                      if UIApplication.shared.canOpenURL(url) {
                        UIApplication.shared.open(url)
                      } else {
                        noPlayCover = true
                      }
                    }
                  } label: {
                    Label("Add VIP Source to PlayCover", systemImage: "airplane.departure")
                      .font(.caption2.bold())
                      .frame(maxWidth: .infinity)
                  }
                  .softButtonStyle(
                    RoundedRectangle(cornerRadius: 7.5),
                    padding: 10,
                    mainColor: .red,
                    textColor: .white,
                    darkShadowColor: .redNeuDS,
                    lightShadowColor: .redNeuLS,
                    pressedEffect: .flat
                  )
                  .padding(.top)
                  .modifier(NoPlayCoverAlert(noPlayCover: $noPlayCover))
                }
                Button {
                  if userVM.userPAT.isEmpty {
                    patreonVM.patreonAPI!.doOAuth()
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
                      Label("Unlink Patreon (\(patreonVM.patronIdentity?.data.attributes.full_name ?? ""))", systemImage: "personalhotspot")
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
                .alert("Are you sure?", isPresented: $presentPatreonUnlink) {
                  Button("Yes, Unlink!", role: .none) {
                    Task {
                      await handlePatreonUnlink()
                    }
                  }
                  Button("Cancel", role: .cancel) { return }
                } message: {
                  Text("Disconnecting your Patreon account from DecryptKit will result in the revocation of your current privileges, but it shall not result in your unsubscription from our Patreon page.")
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
        } else if !userVM.userPAT.isEmpty && !patreonVM.patronTokensFetched {
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
    .onChange(of: patreonVM.patronTokensFetched) { boolean in
      Task {
        if boolean {
          patreonVM.patronIdentity = await patreonVM.patreonAPI!.getUserIdentity(userAccessToken: userVM.userPAT)
        }
      }
    }
  }

  func handleOAuthCallback(_ callbackCode: String) async {
    patreonVM.patreonOAuth = await patreonVM.patreonAPI!.getOAuthTokens(callbackCode: callbackCode)
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
    patreonVM.patronTokensFetched = true
  }

  func handleRefreshToken(_ refreshToken: String) async {
    patreonVM.patreonOAuth = await patreonVM.patreonAPI!.refreshOAuthTokens(userRefreshToken: refreshToken)
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
    patreonVM.patronTokensFetched = true
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
