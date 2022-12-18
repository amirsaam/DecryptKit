//
//  MainView.swift
//  DecryptKit
//
//  Created by Amir Mohammadi on 9/17/1401 AP.
//

import SwiftUI
import Neumorphic
import RealmSwift

struct MainView: View {
  
  @Environment(\.openURL) var openURL
  
  @ObservedResults(deUser.self) var users
  @State var newUser = deUser()

  @State var user: User
  @State var userEmailAddress: String = ""

  @State var showSafari: Bool = false
  @State var showRepo: Bool = false
  @State var showLookup: Bool = false
  
  var body: some View {
    ZStack {
      mainColor
        .ignoresSafeArea(.all)
      GeometryReader { geo in
        VStack {
          HStack(alignment: .center, spacing: geo.size.width * (0.25/10)) {
            VStack {
              BrandInfo(logoSize: geo.size.width * (2/10))
              LogoutButton()
                .padding(.top)
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
                    if let url = URL(string: "playcover:source?action=add&url=https://repo.decryptkit.xyz/ZGVjcnlwdGVkLmpzb24=") {
                      openURL(url)
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
                  Button {
                    withAnimation(.spring()) {
                      showLookup = false
                      showRepo.toggle()
                    }
                  } label: {
                    Image(systemName: "app.badge")
                  }
                  .softButtonStyle(
                    RoundedRectangle(cornerRadius: 15),
                    pressedEffect: .flat
                  )
                  .disabled(showRepo == true ? true : false)
                  Button {
                    withAnimation(.spring()) {
                      showRepo = false
                      showLookup.toggle()
                    }
                  } label: {
                    Label("Request Decryption", systemImage: "plus.app")
                  }
                  .softButtonStyle(
                    RoundedRectangle(cornerRadius: 15),
                    pressedEffect: .flat
                  )
                  .disabled(showLookup == true ? true : false)
                }
                .padding(.top)
              }
              VStack(alignment: .leading, spacing: 5.0) {
                HStack {
                  Text("If you wish help this repo on maintain costs")
                    .font(.footnote)
                  Label("Donate", systemImage: "gift.fill")
                    .font(.caption)
                    .foregroundColor(.red)
                    .onTapGesture {
                      showSafari.toggle()
                    }
                    .fullScreenCover(
                      isPresented: $showSafari,
                      content: {
                        SFSafariViewWrapper(url: URL(string: "https://patreon.com/user?u=84453845&utm_medium=clipboard_copy&utm_source=copyLink&utm_campaign=creatorshare_creator&utm_content=join_link")!)
                      }
                    )
                  Text("is the only option")
                    .font(.footnote)
                }
                Text("Don't forget to enter your Email Address to get our future surprises!")
                  .font(.caption)
              }
            }
            .foregroundColor(secondaryColor)
            .frame(width: geo.size.width * (4.25/10))
            if showLookup {
              LookupView(showLookup: $showLookup,
                         userEmailAddress: $userEmailAddress)
            } else if showRepo {
              RepoView(showRepo: $showRepo)
            } else {
              VStack {
                Creators()
              }
            }
          }
        }
        .foregroundColor(secondaryColor)
        .padding(.leading, geo.size.width * (0.5/10))
      }
    }
    .onAppear {
      if user.customData.isEmpty {
        userEmailAddress = defaults.string(forKey: "Email") ?? ""
        newUser.userId = user.id
        newUser.userEmail = userEmailAddress
        $users.append(newUser)
      } else {
        user.refreshCustomData { (result) in
          switch result {
          case .failure(let error):
            print("Failed to refresh custom data: \(error.localizedDescription)")
          case .success(let customData):
            userEmailAddress = customData["userEmail"] as! String
          }
        }
      }
    }
  }
}
