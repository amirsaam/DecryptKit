//
//  ContentView.swift
//  Source
//
//  Created by Amir Mohammadi on 8/29/1401 AP.
//

import SwiftUI
import Neumorphic

struct ContentView: View {
  
  @Environment(\.openURL) var openURL
  
  @State var isRotating = 0.0
  @State var showSafari: Bool = false
  @State var showLookup: Bool = false
  @State var searchSuccess: Bool = false
  @State var lookedup: ITunesResponse?
  @State var lookedupIcon: String?

  @State var appID: String = ""
  @State var appAttempts: Int = 0
  
  @State var emailAddress: String = ""
  @State var emailIsValid: Bool = false
  @State var emailAttempts: Int = 0
  
  var body: some View {
    ZStack {
      mainColor
        .ignoresSafeArea(.all)
      GeometryReader { geo in
        VStack {
          HStack(alignment: .center, spacing: geo.size.width * (0.25/10)) {
            VStack(alignment: .center) {
              Image("Source")
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
                Text("R  E  P  O")
                  .font(.largeTitle)
                  .fontWeight(.black)
                Text("amrsm.ir")
                  .font(.largeTitle)
                  .fontWeight(.medium)
              }
              .foregroundColor(.invertNeuPC)
            }
            .softOuterShadow()
            VStack(alignment: .leading, spacing: geo.size.width * (0.35/10)) {
              Text("Thank you for choosing this Repo!")
                .font(.title)
                .fontWeight(.heavy)
              VStack(alignment: .leading, spacing: geo.size.width * (0.25/10)) {
                Text("This IPA Repository is non-profit and just for ease of PlayCover users and Mac Gaming Community")
                  .font(.headline)
                  .fontWeight(.medium)
                Text("If you are a IPA Decryptor willing to donate your time to this community, feel free to drop in `amirsaam#3579` DM on Discord")
                  .font(.subheadline)
                  .fontWeight(.medium)
                HStack(alignment: .center, spacing: 25.0) {
                  Button {
                    if let url = URL(string: "playcover:source?action=add&url=repo.amrsm.ir/decrypted.json") {
                      openURL(url)
                    }
                  } label: {
                    Label("Add to PlayCover", systemImage: "airplane.departure")
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
                      showLookup.toggle()
                    }
                  } label: {
                    Label("Request Decryption", systemImage: "plus.app.fill")
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
            ZStack {
              if showLookup {
                Rectangle()
                  .fill(mainColor)
                  .transition(.move(edge: .trailing))
                  .zIndex(1)
                  .ignoresSafeArea(.all)
                  .softOuterShadow()
                  .overlay {
                    VStack(alignment: .leading, spacing: 25.0) {
                      Text("We have an `IPA Decryption` service, thanks to dear `Amachi`!")
                        .font(.headline)
                      if !searchSuccess {
                        Text("*you need to use id numbers from app store share links, e.g `1517783697`*")
                          .font(.footnote)
                      } else {
                        VStack(alignment: .leading, spacing: 10) {
                          HStack(spacing: 10) {
                            if let url = URL(string: lookedupIcon ?? "") {
                              AsyncImage(url: url) { image in
                                image
                                  .resizable()
                                  .aspectRatio(contentMode: .fit)
                              } placeholder: {
                                ProgressView()
                              }
                              .frame(width: 40, height: 40)
                              .cornerRadius(12)
                              .softOuterShadow()
                            }
                            VStack(alignment: .leading, spacing: 5) {
                              HStack(alignment: .center) {
                                Text(lookedup?.results[0].trackName ?? "")
                                  .font(.headline)
                                Text(lookedup?.results[0].formattedPrice ?? "")
                                  .font(.caption)
                              }
                              Text("by \(lookedup?.results[0].artistName ?? "")")
                                .font(.caption)
                            }
                          }
                          HStack(spacing: 5) {
                            Text("Version: \(lookedup?.results[0].version ?? "")")
                            Divider()
                              .frame(height: 5)
                              .foregroundColor(.invertNeuPC)
                            Text(lookedup?.results[0].genres[0] ?? "")
                          }
                          .font(.caption)
                        }
                        .padding(.top)
                      }
                      VStack(alignment: .leading) {
                        TextField("Enter App/Game ID Here", text: $appID)
                          .modifier(Shake(animatableData: CGFloat(appAttempts)))
                          .onSubmit {
                            if appID.isEmpty {
                              withAnimation(.default) {
                                self.appAttempts += 1
                                searchSuccess = false
                              }
                            } else {
                              doGetLookup(appID)
                              withAnimation {
                                searchSuccess = true
                              }
                            }
                          }
                        if searchSuccess {
                          Divider()
                          TextField("Enter Your Email Address", text: $emailAddress)
                            .modifier(Shake(animatableData: CGFloat(emailAttempts)))
                            .textInputAutocapitalization(.never)
                            .autocorrectionDisabled(true)
                          HStack {
                            Spacer()
                            Button {
                              emailIsValid = isValidEmailAddress(emailAddressString: emailAddress)
                              if emailAddress.isEmpty || !emailIsValid {
                                withAnimation(.default) {
                                  self.emailAttempts += 1
                                }
                              } else {
                                
                              }
                            } label: {
                              Label("Send Request", systemImage: "paperplane.fill")
                                .font(.caption2)
                            }
                            .softButtonStyle(
                              RoundedRectangle(cornerRadius: 5),
                              padding: 8
                            )
                            .padding([.top, .trailing])
                          }
                          Text("Download links will be emailed to your address, so make sure to enter a valid and available address!")
                            .font(.footnote)
                            .padding(.top)
                        }
                        if !searchSuccess {
                          Text("*press return after*")
                            .font(.subheadline)
                        }
                      }
                    }
                    .frame(width: geo.size.width * (2.25/10))
                  }
              } else {
                ZStack {
                  mainColor
                  VStack(alignment: .leading) {
                    Text("Special Thanks to:")
                      .font(.subheadline)
                    Text("`Amachi -アマチ#1131`")
                  }
                }
              }
            }
          }
        }
        .foregroundColor(secondaryColor)
        .padding(.leading, geo.size.width * (0.5/10))
      }
    }
  }
  func doGetLookup(_ appid: String) {
    Task {
      lookedup = await getITunesData(appid)
      lookedupIcon = await getITunesData(appid)?.results[0].artworkUrl60
    }
  }
}

struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    ContentView()
  }
}
