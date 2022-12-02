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
  @Binding var sourceData: [deCrippleSource]?

  @State var lookedup: ITunesResponse?
  @State var deResult: deCrippleResult?

  @State var searchSuccess: Bool = false

  @State var inputID: String = ""
  @State var idIsValid: Bool = false
  @State var idIsPaid: Bool = false
  @State var idOnSource: Bool = false
  @State var appAttempts: Int = 0

  @State var emailAddress: String = ""
  @State var emailIsValid: Bool = false
  @State var emailAttempts: Int = 0

  @State var promoCode: String = ""

  var body: some View {
    GeometryReader { geo in
      ZStack {
        if showLookup {
          SidebarBackground()
            .overlay {
              VStack(alignment: .leading, spacing: 25.0) {
                Text("We have an IPA Decryption service, thanks to dear Amachi!")
                  .font(.headline)
                if !searchSuccess {
                  Text("you need to use app store links or the number in the end of it, e.g 1517783697")
                    .font(.footnote.italic())
                } else {
                  if lookedup != nil && idIsValid {
                    LookupAppDetails(lookedup: $lookedup)
                  } else {
                    ErrorMessage(errorLog: "AppStore Link or ID is not correct!")
                  }
                }
                VStack(alignment: .leading) {
                  TextField("Enter AppStore Link or ID Here", text: $inputID)
                    .modifier(Shake(animatableData: CGFloat(appAttempts)))
                    .disabled(idIsValid && searchSuccess && !inputID.isEmpty)
                    .onSubmit {
                      if inputID.isEmpty {
                        withAnimation(.default) {
                          self.appAttempts += 1
                          searchSuccess = false
                        }
                      } else {
                        doGetLookup(inputID)
                        emailAddress = defaults.string(forKey: "Email") ?? ""
                        withAnimation {
                          searchSuccess = true
                        }
                      }
                    }
                  if searchSuccess && idIsValid {
                    Divider()
                    if idIsPaid {
                      ErrorMessage(errorLog: "DecryptKit does not support paid apps!")
                    } else if idOnSource {
                      ErrorMessage(errorLog: "This app is already on DecryptKit source!")
                    } else {
                      TextField("Enter Your Email Address", text: $emailAddress)
                        .modifier(Shake(animatableData: CGFloat(emailAttempts)))
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled(true)
                      Divider()
                      TextField("Promo Code?", text: $promoCode)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled(true)
                    }
                    HStack {
                      Button {
                        withAnimation {
                          inputID = ""
                          searchSuccess = false
                          lookedup = nil
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
                        if inputID.isEmpty {
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
                            defaults.set(emailAddress, forKey: "Email")
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
                      .disabled(!idIsValid || idIsPaid || idOnSource)
                    }
                    .padding(.top)
                    Text("Download links will be emailed to your address, so make sure to enter a valid and available address!")
                      .font(.footnote)
                      .padding(.top)
                  } else {
                    Text("press return after")
                      .font(.subheadline.italic())
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
        }
      }
    }
  }
  func doGetLookup(_ input: String) {
    Task {
      var id: String
      if input.hasPrefix("https") {
        let components = input.components(separatedBy: "/")
        id = String(components.last?.replacingOccurrences(of: "id", with: "") ?? "")
      } else {
        id = input
      }
      lookedup = await getITunesData(id)
      idIsValid = lookedup?.resultCount == 1 ? true : false
      if idIsValid {
        idIsPaid = lookedup?.results[0].price != 0 ? true : false
        if idIsValid && !idIsPaid {
          idOnSource = sourceData?.first?.bundleID == lookedup?.results[0].bundleId ? true : false
        }
      }
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
