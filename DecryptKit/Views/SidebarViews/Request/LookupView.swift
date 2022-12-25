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
  @Binding var sourceData: [deCrippleSource]?
  
  @ObservedResults(deStat.self) private var stats
  @State private var newStat = deStat()

  @State private var lookedup: ITunesResponse?
  @State private var deResult: deCrippleResult?
  
  @State private var searchSuccess: Bool = false
  
  @State private var inputID: String = ""
  @State private var appAttempts: Int = 0

  @State private var idIsValid: Bool = false
  @State private var idIsPaid: Bool = false
  @State private var idOnSource: Bool = false
  
  @State private var promoCode: String = ""
  
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
                      searchApp()
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
                      searchApp()
                    } label: {
                      Label("Search...", systemImage: "magnifyingglass")
                        .font(.caption2)
                    }
                    .softButtonStyle(
                      RoundedRectangle(cornerRadius: 10),
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
  func searchApp() {
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
    let realm = stats.realm!.thaw()
    let thawedStats = stats.thaw()!
    let stat = thawedStats.where {
      $0.lookedId.contains(id)
    }
    if stat.isEmpty {
      debugPrint("Appending stat for \(id) to deStat")
      newStat.lookedId = lookedup?.results[0].bundleId ?? ""
      newStat.lookersEmail.append(userEmailAddress)
      newStat.lookersStat = 1
      newStat.lookStats = 1
      $stats.append(newStat)
    } else {
      let statToUpdate = stat[0]
      if statToUpdate.lookersEmail.contains(userEmailAddress) {
        debugPrint("\(userEmailAddress) is already in stat for \(id)")
        try! realm.write {
          statToUpdate.lookStats += 1
        }
      } else {
        debugPrint("Appending \(userEmailAddress) to stat for \(id)")
        try! realm.write {
          statToUpdate.lookersEmail.append(userEmailAddress)
          statToUpdate.lookersStat += 1
          statToUpdate.lookStats += 1
        }
      }
    }
  }
  // func doRequest(_ id: String, _ email: String, _ promo: String) {
  func doRequest(_ id: String, _ email: String) {
    Task {
      // deCripple = await reqDecrypt(id, email, promo)
      deResult = await reqDecrypt(id, email)
    }
  }
}
