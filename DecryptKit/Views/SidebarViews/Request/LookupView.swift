//
//  LookupStack.swift
//  deCripple
//
//  Created by Amir Mohammadi on 9/3/1401 AP.
//

import SwiftUI
import Neumorphic
import RealmSwift

// MARK: - View Struct
struct LookupView: View {
  
  @Binding var showLookup: Bool

  @ObservedResults(deStat.self) private var stats
  @ObservedResults(deReq.self) private var requests
  
  @State private var activeReqs: [deReq] = []

  @State private var freeSourceData = SourceVM.shared.freeSourceData
  @State private var userEmailAddress = UserVM.shared.userEmail
  @State private var requestProgress = false
  @State private var requestSubmitted = false
  @State private var serviceIsOn = false
  @State private var deResult = ""

  @State private var searchSuccess = false
  @State private var inputID = ""
  @State private var appAttempts = 0

  @State private var lookedup: ITunesResponse?
  @State private var idIsValid = false
  @State private var idIsPaid = false
  @State private var idOnSource = false
  @State private var reqLimit = UserVM.shared.userTier == 0 ? 1 : UserVM.shared.userTier < 3 ? 3 : 5

  // MARK: - View Body
  var body: some View {
    GeometryReader { geo in
      ZStack {
        if showLookup {
          SidebarBackground()
            .overlay {
              VStack(alignment: .leading, spacing: 25.0) {
                if activeReqs.isEmpty {
                  Text("Our IPA Decryption service is made available through the generosity of dear Amachi!")
                    .font(.headline)
                } else {
                  Text("Your Active Requests:")
                    .font(.subheadline.monospaced().bold())
                  VStack(spacing: 10) {
                    ForEach(activeReqs, id: \.requestedId) { req in
                      HStack {
                        RequestsAppDetails(bundleId: req.requestedId)
                        Spacer()
                        Button {
                          Task {
                            await removeRequestFromQueue(bundleId: req.requestedId)
                          }
                        } label: {
                          Image(systemName: "trash.fill")
                        }
                        .softButtonStyle(
                          Circle(),
                          padding: 8,
                          textColor: .red,
                          pressedEffect: .flat
                        )
                      }
                    }
                  }
                }
                Divider()
                Text("Decryption Request Form:")
                  .font(.subheadline.monospaced().bold())
                if !searchSuccess {
                  Text("Utilization of either the app store links or the numerical code at the end is required.\n" +
                       "e.g. 1517783697")
                    .font(.footnote.italic())
                } else {
                  if lookedup != nil && (idIsValid || idOnSource || idIsPaid) {
                    SearchAppDetails(lookedup: $lookedup)
                      .task(priority: .background) {
                        if let bundleId = lookedup?.results[0].bundleId {
                          await doAddStat(bundleId: bundleId)
                        }
                      }
                    if idIsPaid {
                      ErrorMessage(errorLog: "We do not offer decryption for paid apps.")
                    } else if idOnSource {
                      ErrorMessage(errorLog: "It's already present within the public source.")
                    } else if activeReqs.count >= reqLimit {
                      ErrorMessage(errorLog: "You have reached your active request limit.")
                    }
                  } else {
                    ErrorMessage(errorLog: "Incorrect App Store Link or ID.")
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
                        Text(deResult)
                        if !serviceIsOn {
                          Label("The process of decryption may be temporarily delayed due to a high volume of demand.",
                                systemImage: "exclamationmark.triangle.fill")
                          .font(.caption)
                          .foregroundColor(.red)
                          .padding(.top, 1)
                        }
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
                            Task {
                              if let bundleId = lookedup?.results[0].bundleId {
                                await doRequest(bundleId: bundleId)
                              }
                            }
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
                      .disabled(requestProgress || requestSubmitted || activeReqs.count >= reqLimit)
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
      if freeSourceData == nil {
        await resolveSourceData()
      }
      freeSourceData = SourceVM.shared.freeSourceData
      await retrieveActiveReqs()
    }
  }

  // MARK: -
  func retrieveActiveReqs() async {
    let thawedReqs = requests.thaw()!
    let requests = thawedReqs.where {
      $0.requestersEmail.contains(userEmailAddress)
    }
    requests.forEach { req in
      withAnimation {
        activeReqs.append(req)
      }
    }
  }

  // MARK: -
  func removeRequestFromQueue(bundleId: String) async {
    let realm = requests.realm!.thaw()
    let thawedReqs = requests.thaw()!
    let request = thawedReqs.where {
      $0.requestedId.contains(bundleId) && $0.requestersEmail.contains(userEmailAddress)
    }
    activeReqs = []
    let reqToUpdate = request[0]
    if reqToUpdate.requestersEmail.count > 1 {
      try! realm.write {
        if let index = reqToUpdate.requestersEmail.firstIndex(of: userEmailAddress) {
          reqToUpdate.requestersEmail.remove(at: index)
        }
      }
    } else {
      try! realm.write {
        $requests.remove(reqToUpdate)
      }
    }
    await retrieveActiveReqs()
  }

  // MARK: - Search Button and Function
  func searchApp() {
    lookedup = nil
    if inputID.isEmpty {
      withAnimation(.default) {
        self.appAttempts += 1
        searchSuccess = false
      }
    } else {
      doGetLookup(input: inputID)
      withAnimation {
        searchSuccess = true
      }
    }
  }

  // MARK: - Get Lookup Function
  func doGetLookup(input: String) {
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
      if idIsValid && UserVM.shared.userTier < 4 {
        idOnSource = freeSourceData?.contains { app in
          app.bundleID == lookedup?.results[0].bundleId ?? ""
        } ?? false
        idIsPaid = lookedup?.results[0].price != 0
        if idOnSource || idIsPaid {
          idIsValid = false
        }
      }
    }
  }

  // MARK: - Add Stat Function
  func doAddStat(bundleId: String) async {
    let newStat = deStat()
    let realm = stats.realm!.thaw()
    let thawedStats = stats.thaw()!
    let stat = thawedStats.where {
      $0.lookedId.contains(bundleId)
    }
    if stat.isEmpty {
      debugPrint("Appending stat for \(bundleId) to deStat")
      newStat.lookedId = lookedup?.results[0].bundleId ?? ""
      newStat.lookersEmail.append(userEmailAddress)
      newStat.lookersStat = 1
      newStat.lookStats = 1
      $stats.append(newStat)
    } else {
      let statToUpdate = stat[0]
      if statToUpdate.lookersEmail.contains(userEmailAddress) {
        debugPrint("\(userEmailAddress) is already in stat for \(bundleId)")
        try! realm.write {
          statToUpdate.lookStats += 1
        }
      } else {
        debugPrint("Appending \(userEmailAddress) to stat for \(bundleId)")
        try! realm.write {
          statToUpdate.lookersEmail.append(userEmailAddress)
          statToUpdate.lookersStat += 1
          statToUpdate.lookStats += 1
        }
      }
    }
  }

  // MARK: - Send Request Function
  func doRequest(bundleId: String) async {
    let newReq = deReq()
    serviceIsOn = await isServiceRunning()
    let realm = requests.realm!.thaw()
    let thawedReqs = requests.thaw()!
    let request = thawedReqs.where {
      $0.requestedId.contains(bundleId)
    }
    if request.isEmpty {
      debugPrint("Appending request for \(bundleId) to deReq")
      newReq.requestedId = lookedup?.results[0].bundleId ?? ""
      newReq.requestersEmail.append(userEmailAddress)
      $requests.append(newReq)
      deResult = "Your request has been added to queue"
    } else {
      let reqToUpdate = request[0]
      if reqToUpdate.requestersEmail.contains(userEmailAddress) {
        debugPrint("\(userEmailAddress) already requested \(bundleId)")
        deResult = "Your request is already in queue"
      } else {
        debugPrint("Appending \(userEmailAddress) to requests for \(bundleId)")
        try! realm.write {
          reqToUpdate.requestersEmail.append(userEmailAddress)
        }
        deResult = "Your request has been added to queue"
      }
    }
    activeReqs.removeAll()
    await retrieveActiveReqs()
  }

}
