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
  @ObservedResults(deReq.self) private var requests
  @State private var newReq = deReq()
  @State private var requestProgress = false
  @State private var requestSubmitted = false
  @State private var deResult: String?

  @State private var searchSuccess: Bool = false
  @State private var inputID: String = ""
  @State private var appAttempts: Int = 0

  @State private var lookedup: ITunesResponse?
  @State private var idIsValid: Bool = false
  @State private var idIsPaid: Bool = false
  @State private var idOnSource: Bool = false

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
                      if requestSubmitted {
                        Divider()
                        Text(deResult ?? "")
                      }
                    }
                    HStack {
                      Button {
                        withAnimation {
                          inputID = ""
                          searchSuccess = false
                          lookedup = nil
                          requestSubmitted = false
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
                        Task {
                          withAnimation {
                            requestProgress = true
                          }
                          try? await Task.sleep(nanoseconds: 3000000000)
                          withAnimation {
                            requestProgress = false
                            doRequest((lookedup?.results[0].bundleId)!)
                            requestSubmitted = true
                          }
                        }
                      } label: {
                        if requestProgress {
                          Label("Submitting", systemImage: "circle.dotted")
                            .font(.caption2)
                        } else if requestSubmitted {
                          Label("Submited", systemImage: "checkmark")
                            .font(.caption2)
                        } else {
                          Label("Request", systemImage: "paperplane.fill")
                            .font(.caption2)
                        }
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
                      .disabled(requestProgress || requestSubmitted)
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
      sourceData = try? cache.readCodable(forKey: "cachedSourceData")
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
  func doRequest(_ id: String) {
    let realm = requests.realm!.thaw()
    let thawedReqs = requests.thaw()!
    let request = thawedReqs.where {
      $0.requestedId.contains(id)
    }
    if request.isEmpty {
      debugPrint("Appending request for \(id) to deReq")
      newReq.requestedId = lookedup?.results[0].bundleId ?? ""
      newReq.requestersEmail.append(userEmailAddress)
      $requests.append(newReq)
      deResult = "Your request has been added to queue"
    } else {
      let reqToUpdate = request[0]
      if reqToUpdate.requestersEmail.contains(userEmailAddress) {
        debugPrint("\(userEmailAddress) already requested \(id)")
        deResult = "Your request is already in queue"
      } else {
        debugPrint("Appending \(userEmailAddress) to requests for \(id)")
        try! realm.write {
          reqToUpdate.requestersEmail.append(userEmailAddress)
        }
        deResult = "Your request has been added to queue"
      }
    }
  }
}
