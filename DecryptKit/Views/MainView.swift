//
//  MainView.swift
//  deCripple
//
//  Created by Amir Mohammadi on 9/17/1401 AP.
//

import SwiftUI
import Neumorphic
import RealmSwift

// MARK: - View Struct
struct MainView: View {

  @Environment(\.openURL) private var openURL
  @EnvironmentObject var errorHandler: ErrorHandler

  @State var user: User
  @Binding var userUID: String
  @Binding var userIsBanned: Bool
  @Binding var userEmailAddress: String
  @Binding var userTier: Int
  @Binding var userPAT: String
  @Binding var userPRT: String
  @Binding var dataLoaded: Bool
  @Binding var sourceData: [deCrippleSource]?

  @ObservedResults(deUser.self) private var users
  @State private var newUser = deUser()

  @State private var noPlayCover = false
  @State private var showRepo = false
  @State private var showLookup = false
  @State private var showPatreon = false
  @State private var isDeeplink = false
  @State private var tokensFetched = false

  @State private var patreonCallbackCode: String = ""
  @State private var patreonCallbackState: String = ""

  // MARK: - View Body
  var body: some View {
    GeometryReader { geo in
      if userIsBanned {
        HStack {
          Spacer()
          VStack {
            Spacer()
            Text("This account has been Restricted!")
              .font(.title.monospaced())
            Text("support@decryptkit.xyz")
              .font(.headline.monospaced())
              .padding(.top)
            Text("Contact above Email Address for more Information")
              .font(.headline.monospaced())
              .padding(.top, 1)
            Spacer()
          }
          Spacer()
        }
      } else {
        if dataLoaded {
          VStack {
            HStack(alignment: .center, spacing: geo.size.width * (0.25/10)) {
              VStack {
                BrandInfo(logoSize: geo.size.width * (2/10))
                SignOutButton()
                  .padding(.top, 1)
              }
              VStack(alignment: .leading, spacing: geo.size.width * (0.35/10)) {
                Text("The Decrypted IPAs, made easy!")
                  .fontWeight(.heavy)
                  .font(.title.monospaced())
                VStack(alignment: .leading, spacing: geo.size.width * (0.25/10)) {
                  Text("DecryptKit is a free to use IPA Repository & Decrypting Service created just for ease of PlayCover users and Mac Gaming Community.")
                    .font(.headline)
                    .fontWeight(.medium)
                  VStack(alignment: .leading) {
                    Text("If you are a IPA Decryptor willing to donate your time to this community,")
                      .fontWeight(.medium)
                    Text("feel free to drop in DecryptKit creators DM on Discord!")
                      .fontWeight(.medium)
                  }
                  .font(.subheadline)
                  HStack(alignment: .center, spacing: 25.0) {
                    Button {
                      if let url = playcoverURL {
                        if UIApplication.shared.canOpenURL(url) {
                          openURL(url)
                        } else {
                          noPlayCover = true
                        }
                      }
                    } label: {
                      Label("Add Source to PlayCover", systemImage: "airplane.departure")
                    }
                    .softButtonStyle(
                      RoundedRectangle(cornerRadius: 15),
                      mainColor: .red,
                      textColor: .white,
                      darkShadowColor: .redNeuDS,
                      lightShadowColor: .redNeuLS,
                      pressedEffect: .flat
                    )
                    .alert("PlayCover is not Installed!", isPresented: $noPlayCover) {
                      Button("Install PlayCover", role: .destructive) {
                        if let url = URL(string: "https://github.com/PlayCover/PlayCover/releases") {
                          openURL(url)
                        }
                      }
                      Button("Cancel", role: .cancel) { return }
                    } message: {
                      Text("You need to have PlayCover installed in order to use DecryptKit IPA Source.")
                    }
                    Button {
                      withAnimation(.spring()) {
                        (showLookup, showPatreon) = (false, false)
                        showRepo.toggle()
                      }
                    } label: {
                      Image(systemName: "app.badge")
                    }
                    .softButtonStyle(
                      RoundedRectangle(cornerRadius: 15),
                      pressedEffect: .flat
                    )
                    .disabled(showRepo)
                    Button {
                      withAnimation(.spring()) {
                        (showRepo, showPatreon) = (false, false)
                        showLookup.toggle()
                      }
                    } label: {
                      Label("Request Decryption", systemImage: "plus.app")
                    }
                    .softButtonStyle(
                      RoundedRectangle(cornerRadius: 15),
                      pressedEffect: .flat
                    )
                    .disabled(showLookup)
                  }
                  .padding(.top)
                }
                VStack(alignment: .leading, spacing: 5.0) {
                  HStack {
                    Text("If you wish help this repo on maintain costs")
                      .font(.footnote)
                    Button {
                      withAnimation(.spring()) {
                        (showRepo, showLookup) = (false, false)
                        showPatreon.toggle()
                      }
                    } label: {
                      Label("Patreon", systemImage: "giftcard.fill")
                        .font(.caption)
                        .foregroundColor(.red)
                    }
                    .disabled(showPatreon)
                    Text("is the only option")
                      .font(.footnote)
                  }
                  Text("Be aware that our Patrons will gain access to our premium membership services!")
                    .font(.caption)
                }
              }
              .foregroundColor(secondaryColor)
              .frame(width: geo.size.width * (4.25/10))
              if showLookup {
                LookupView(showLookup: $showLookup,
                           userEmailAddress: $userEmailAddress,
                           sourceData: $sourceData)
              } else if showRepo {
                RepoView(showRepo: $showRepo,
                         sourceData: $sourceData)
              } else if showPatreon {
                PatreonView(user: user,
                            isDeeplink: $isDeeplink,
                            tokensFetched: $tokensFetched,
                            showPatreon: $showPatreon,
                            callbackCode: $patreonCallbackCode,
                            userPAT: $userPAT,
                            userPRT: $userPRT)
              } else {
                VStack {
                  Creators()
                }
              }
            }
          }
          .foregroundColor(secondaryColor)
          .padding(.leading, geo.size.width * (0.5/10))
        } else {
          VStack {
            Spacer()
            HStack {
              Spacer()
              BrandProgress(logoSize: 50,
                            progressText: "Loading Data...")
              Spacer()
            }
            Spacer()
          }
        }
      }
    }
    // MARK: - Hnadling URL Schema
    .onOpenURL { url in
      isDeeplink = false
      let callback = url.params()
      if callback.isEmpty {
        debugPrint(url)
      } else {
        debugPrint(url)
        (showRepo, showLookup) = (false, false)
        patreonCallbackCode = callback["code"] as! String
        patreonCallbackState = callback["state"] as! String
        (isDeeplink, showPatreon) = (true, true)
      }
    }
  }
}
