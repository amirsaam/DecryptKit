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
  
  @Environment(\.openURL) var openURL
  
  @ObservedObject var app: RealmSwift.App
  
  @State var sourceData: [deCrippleSource]?
  @State var isRotating = 0.0
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
            VStack(alignment: .center) {
              Image("deCripple")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: geo.size.width * (2/10), height: geo.size.width * (2/10))
                .rotationEffect(.degrees(isRotating))
                .onAppear {
                  withAnimation(
                    .linear(duration: 1)
                    .speed(0.1)
                    .repeatForever(autoreverses: false)
                  ) {
                    isRotating = 360.0
                  }
                }
              Group {
                Text("DecryptKit")
                  .font(.largeTitle.monospaced())
                  .fontWeight(.bold)
                Text("repo.DecryptKit.tech")
                  .font(.title3.lowercaseSmallCaps())
                  .fontWeight(.medium)
              }
              .foregroundColor(.invertNeuPC)
            }
            .softOuterShadow()
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
                    if let url = URL(string: "playcover:source?action=add&url=https://repo.decryptkit.tech/ZGVjcnlwdGVkLmpzb24=") {
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
                        SFSafariViewWrapper(url: URL(string: "https://reymit.ir/amirsaam")!)
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
                         sourceData: $sourceData)
            } else if showRepo {
              RepoView(showRepo: $showRepo,
                       sourceData: $sourceData)
            } else {
              Creators()
            }
          }
        }
        .foregroundColor(secondaryColor)
        .padding(.leading, geo.size.width * (0.5/10))
      }
    }
    .accentColor(.red)
    .task {
      sourceData = await getSourceData()
    }
  }
}

struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    ContentView(app: realmApp)
  }
}
