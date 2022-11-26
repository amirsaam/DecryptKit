//
//  LookupStack.swift
//  deCripple
//
//  Created by Amir Mohammadi on 9/3/1401 AP.
//

import SwiftUI
import Neumorphic

struct LookupView: View {
  
  @Binding var showLookup: Bool
  
  @State var lookedup: ITunesResponse?
  @State var deResult: deCrippleResult?
  @State var deSource: [deCrippleSource]?
  
  @State var searchSuccess: Bool = false
  
  @State var appLink: String = ""
  @State var idIsValid: Bool = false
  @State var idIsFree: Bool = false
  @State var idOnSource: Bool = false
  @State var appAttempts: Int = 0
  
  @State var emailAddress: String = ""
  @State var emailIsValid: Bool = false
  @State var emailAttempts: Int = 0
  
  @State var promoCode: String? = ""
  
  var body: some View {
    GeometryReader { geo in
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
                  if idIsValid {
                    VStack(alignment: .leading, spacing: 10) {
                      HStack(spacing: 10) {
                        if let url = URL(string: lookedup?.results[0].artworkUrl60 ?? "") {
                          AsyncImage(url: url) { image in
                            image
                              .resizable()
                              .aspectRatio(contentMode: .fit)
                          } placeholder: {
                            ProgressView()
                          }
                          .frame(width: 45, height: 45)
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
                          .frame(height: 10)
                          .foregroundColor(.invertNeuPC)
                        Text(lookedup?.results[0].genres[0] ?? "")
                      }
                      .font(.caption)
                    }
                    .padding(.top)
                  } else {
                    Text("AppStore ID is not correct!")
                      .font(.subheadline)
                      .foregroundColor(.red)
                  }
                }
                VStack(alignment: .leading) {
                  TextField("Enter AppStore ID Here", text: $appLink)
                    .modifier(Shake(animatableData: CGFloat(appAttempts)))
                    .disabled(idIsValid && searchSuccess && !appLink.isEmpty)
                    .onSubmit {
                      if appLink.isEmpty {
                        withAnimation(.default) {
                          self.appAttempts += 1
                          searchSuccess = false
                        }
                      } else {
                        doGetLookup(appLink)
                        withAnimation {
                          searchSuccess = true
                        }
                      }
                    }
                  if searchSuccess && idIsValid {
                    Divider()
                    if idIsFree && !idOnSource {
                      TextField("Enter Your Email Address", text: $emailAddress)
                        .modifier(Shake(animatableData: CGFloat(emailAttempts)))
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled(true)
                      Divider()
                      TextField("Promo Code?", text: $emailAddress)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled(true)
                    } else if idOnSource {
                      HStack {
                        Spacer()
                        Text("This app is already on `deCripple` source!")
                          .font(.subheadline)
                          .foregroundColor(.red)
                          .padding(.top)
                        Spacer()
                      }
                    } else {
                      HStack {
                        Spacer()
                        Text("`deCripple` does not support paid apps!")
                          .font(.subheadline)
                          .foregroundColor(.red)
                          .padding(.top)
                        Spacer()
                      }
                    }
                    HStack {
                      Button {
                        withAnimation {
                          appLink = ""
                          searchSuccess = false
                        }
                      } label: {
                        Label("Edit AppStore ID", systemImage: "pencil")
                          .font(.caption2)
                      }
                      .softButtonStyle(
                        RoundedRectangle(cornerRadius: 7.5),
                        padding: 10,
                        pressedEffect: .flat
                      )
                      Spacer()
                      Button {
                        if appLink.isEmpty {
                          withAnimation {
                            self.appAttempts += 1
                            searchSuccess = false
                          }
                        } else {
                          emailIsValid = isValidEmailAddress(emailAddressString: emailAddress)
                          if emailAddress.isEmpty || !emailIsValid {
                            withAnimation(.default) {
                              self.emailAttempts += 1
                            }
                          } else {
//                            doRequest(lookedup?.results[0].bundleId ?? "", emailAddress, promoCode)
                            doRequest(lookedup?.results[0].bundleId ?? "", emailAddress)
                          }
                        }
                      } label: {
                        Label("Send Request", systemImage: "paperplane.fill")
                          .font(.caption2)
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
                      .disabled(!idIsValid || !idIsFree)
                    }
                    .padding(.top)
                    Text("Download links will be emailed to your address, so make sure to enter a valid and available address!")
                      .font(.footnote)
                      .padding(.top)
                  }
                  if !searchSuccess || !idIsValid {
                    Text("*press return after*")
                      .font(.subheadline)
                  }
                }
                HStack {
                  Button {
                    withAnimation(.spring()) {
                      showLookup = false
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
              .frame(width: geo.size.width * (8.25/10))
            }
        } else {
          ZStack {
            mainColor
            VStack(alignment: .leading) {
              Text("`deCripple` Creators:")
                .font(.subheadline)
              Text("`amirsaam#3579`")
                .padding(.top)
              Text("`Amachi -アマチ#1131`")
            }
          }
        }
      }
    }
  }
  func doGetLookup(_ applink: String) {
    Task {
      var id = applink.suffix(10)
      lookedup = await getITunesData(String(id))
      idIsValid = lookedup?.resultCount == 1 ? true : false
      idIsFree = lookedup?.results[0].price == 0 ? true : false
      doGetSource()
    }
  }
  func doGetSource() {
    Task {
      deSource = await getSourceData()
      idOnSource = deSource?.first?.bundleID == lookedup?.results[0].bundleId ? true : false
    }
  }
//  func doRequest(_ id: String, _ email: String, _ promo: String) {
  func doRequest(_ id: String, _ email: String) {
    Task {
//      deCripple = await reqDecrypt(id, email, promo)
      deResult = await reqDecrypt(id, email)
    }
  }
}
