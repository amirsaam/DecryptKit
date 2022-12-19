//
//  LookupStack.swift
//  deCripple
//
//  Created by Amir Mohammadi on 9/3/1401 AP.
//

import SwiftUI
import Neumorphic
import RealmSwift
import DataCache

struct LookupView: View {
  
  @Binding var showLookup: Bool
  @Binding var userEmailAddress: String
  
  @ObservedResults(deStat.self) var stats
  @State var newStat = deStat()

  @State var sourceData: [deCrippleSource]?
  @State var lookedup: ITunesResponse?
  @State var deResult: deCrippleResult?
  
  @State var searchSuccess: Bool = false
  
  @State var inputID: String = ""
  @State var appAttempts: Int = 0

  @State var idIsValid: Bool = false
  @State var idIsPaid: Bool = false
  @State var idOnSource: Bool = false
  
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
                  if lookedup != nil && (idIsValid || idOnSource || idIsPaid) {
                    LookupAppDetails(lookedup: $lookedup)
                      .onAppear {
                        if lookedup != nil {
                          doAddStat((lookedup?.results[0].bundleId)!)
                        }
                      }
                    if idIsPaid {
                      ErrorMessage(errorLog: "DecryptKit does not support paid apps!")
                    } else if idOnSource {
                      ErrorMessage(errorLog: "This app is already on DecryptKit source!")
                    }
                  } else {
                    ErrorMessage(errorLog: "AppStore Link or ID is not correct!")
                  }
                }
                VStack(alignment: .leading) {
                  TextField("Enter AppStore Link or ID Here", text: $inputID)
                    .modifier(Shake(animatableData: CGFloat(appAttempts)))
                    .disabled(idIsValid && searchSuccess && !inputID.isEmpty)
                    .onSubmit {
                      submitApp()
                    }
                  if searchSuccess && idIsValid {
                    Divider()
                    if !idIsPaid && !idOnSource {
                      TextField("Enter Your Email Address", text: $userEmailAddress)
                        .disabled(true)
                      Divider()
                      TextField("Promo Code (Optional)", text: $promoCode)
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
                        Label("Clear", systemImage: "xmark")
                          .font(.caption2)
                      }
                      .softButtonStyle(
                        RoundedRectangle(cornerRadius: 7.5),
                        padding: 10,
                        pressedEffect: .flat
                      )
                      Spacer()
                      Button {
                        // doRequest(lookedup?.results[0].bundleId ?? "", emailAddress, promoCode)
                        doRequest(lookedup?.results[0].bundleId ?? "", userEmailAddress)
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
                    }
                    .padding(.top)
                  } else {
                    Button {
                      submitApp()
                    } label: {
                      Label("Search", systemImage: "magnifyingglass")
                        .font(.caption2)
                    }
                    .softButtonStyle(
                      RoundedRectangle(cornerRadius: 7.5),
                      padding: 10,
                      pressedEffect: .flat
                    )
                    .padding(.top, 10)
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
    .task {
      do {
        sourceData = try DataCache.instance.readCodable(forKey: "cachedSourceData")
      } catch {
        print("Read error \(error.localizedDescription)")
      }
    }
  }
  func submitApp() {
    if inputID.isEmpty {
      withAnimation(.default) {
        self.appAttempts += 1
        searchSuccess = false
      }
    } else {
      doGetLookup(inputID)
      withAnimation {
        searchSuccess = true
      }
    }
  }
  func doGetLookup(_ input: String) {
    Task {
      var id: String
      idOnSource = false
      idIsPaid = false
      if input.hasPrefix("https") {
        let components = input.components(separatedBy: "/")
        id = String(components.last?.replacingOccurrences(of: "id", with: "") ?? "")
      } else {
        id = input
      }
      lookedup = await getITunesData(id)
      idIsValid = lookedup?.resultCount == 1
      if idIsValid {
        idOnSource = sourceData?.contains { app in
          app.bundleID == lookedup?.results[0].bundleId ?? ""
        } ?? false
        idIsPaid = lookedup?.results[0].price != 0
        if idOnSource || idIsPaid {
          idIsValid = false
        }
      }
    }
  }
  func doAddStat(_ id: String) {
    let realm = try! Realm()
    let allObjects = realm.objects(deStat.self)
    let object = allObjects.contains {
      $0.lookedId == id
    }
    print(id)
    print(allObjects.isEmpty)
    print(object)
//    if !object.isEmpty {
//      let newEmail = userEmailAddress
//      if !object.lookersEmail.contains(newEmail) {
//        debugPrint(newEmail)
//        try! realm.write {
//          object.lookersEmail.append(newEmail)
//          object.lookersStat += 1
//          object.lookStats += 1
//          realm.add(object, update: .modified)
//        }
//      } else {
//        debugPrint("no new email for stats")
//        try! realm.write {
//          object.lookStats += 1
//          realm.add(object, update: .modified)
//        }
//      }
//    } else {
//      debugPrint("appending new data to realm")
//      newStat.lookedId = lookedup?.results[0].bundleId ?? ""
//      newStat.lookersEmail.append(userEmailAddress)
//      newStat.lookersStat = 1
//      newStat.lookStats = 1
//      $stats.append(newStat)
//    }
  }
  // func doRequest(_ id: String, _ email: String, _ promo: String) {
  func doRequest(_ id: String, _ email: String) {
    Task {
      // deCripple = await reqDecrypt(id, email, promo)
      deResult = await reqDecrypt(id, email)
    }
  }
}
