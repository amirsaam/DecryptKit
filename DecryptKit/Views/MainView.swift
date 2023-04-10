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

  @Binding var user: User
  @Binding var dataLoaded: Bool

  @EnvironmentObject var errorHandler: ErrorHandler

  @State private var noPlayCover = false
  @State private var showRepo = false
  @State private var showLookup = false
  @State private var showPatreon = false
  @State private var isDeeplink = false

  @State private var patreonCallbackCode: String = ""
  @State private var patreonCallbackState: String = ""

  // MARK: - View Body
  var body: some View {
    GeometryReader { geo in
      if UserVM.shared.userIsBanned {
        RestrictedUser()
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
                Text("Decrypted IPAs, made easy!")
                  .fontWeight(.heavy)
                  .font(.largeTitle.monospaced())
                VStack(alignment: .leading, spacing: geo.size.width * (0.25/10)) {
                  Text("DecryptKit is a gratis IPA Repository and Decrypting Service, crafted for the convenience of PlayCover users and the Mac Gaming Community.")
                    .font(.headline)
                    .fontWeight(.medium)
                  VStack(alignment: .leading) {
                    Text("If you inclined to donate your time as an IPA Decryptor, kindly extend a message to the creators of DecryptKit via Ticket in our Discord Server.")
                      .fontWeight(.medium)
                  }
                  .font(.subheadline)
                  HStack(alignment: .center) {
                    Button {
                      if let url = playcoverPublicURL {
                        if UIApplication.shared.canOpenURL(url) {
                          UIApplication.shared.open(url)
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
                    .modifier(NoPlayCoverAlert(noPlayCover: $noPlayCover))
                    Spacer()
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
                    Spacer()
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
                HStack(spacing: 20.0) {
                  Text("Do you know we have Premium Memberships?")
                    .font(.headline)
                  Button {
                    withAnimation(.spring()) {
                      (showRepo, showLookup) = (false, false)
                      showPatreon.toggle()
                    }
                  } label: {
                    Label("Check our Patreon", systemImage: "giftcard.fill")
                      .font(.headline)
                      .foregroundColor(.red)
                  }
                  .disabled(showPatreon)
                  .buttonStyle(.plain)
                  .softOuterShadow()
                }
              }
              .foregroundColor(secondaryColor)
              .frame(width: geo.size.width * (4.25/10))
              if showLookup {
                LookupView(showLookup: $showLookup)
              } else if showRepo {
                RepoView(showRepo: $showRepo,
                         showPatreon: $showPatreon)
              } else if showPatreon {
                PatreonView(user: user,
                            isDeeplink: $isDeeplink,
                            showPatreon: $showPatreon,
                            callbackCode: $patreonCallbackCode)
                .environmentObject(PatreonVM.shared)
                .environmentObject(UserVM.shared)
              } else {
                Creators()
              }
            }
          }
          .foregroundColor(secondaryColor)
          .padding(.leading, geo.size.width * (0.5/10))
          .overlay {
            if UserVM.shared.userTier == 0 {
              VStack {
                Spacer()
                AdMobView()
                  .padding()
              }
            }
          }
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
