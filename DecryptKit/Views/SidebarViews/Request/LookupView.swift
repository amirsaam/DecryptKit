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

  @State private var freeSourceData = SourceVM.shared.freeSourceData
  @State private var theBlacklist = SourceVM.shared.theBlacklistData
  @State private var userEmailAddress = UserVM.shared.userEmail
  @State private var userReqLimit = UserVM.shared.userReqLimit

  @State private var requestProgress = false
  @State private var requestSubmitted = false
  @State private var serviceIsOn = false
  @State private var resultMessage: deResult = .null
  @State private var readyLink = ""
  @State private var linkCopied = false

  @State private var searchSuccess = false
  @State private var inputID = ""
  @State private var appAttempts = 0

  @State private var lookedup: ITunesResponse?
  @State private var idIsValid = false
  @State private var idIsPaid = false
  @State private var idOnSource = false

  // MARK: - View Body
  var body: some View {
    GeometryReader { geo in
      ZStack {
        if showLookup {
          SidebarBackground()
            .overlay {
              VStack(alignment: .leading, spacing: 25.0) {
                if requests.contains(where: {
                  $0.requestersEmail.contains(userEmailAddress) && $0.requestedIsDecrypted == false
                }) {
                  Text("Your Active Requests:")
                    .font(.subheadline.monospaced().bold())
                  VStack(spacing: 10) {
                    ForEach(requests.filter {
                      $0.requestersEmail.contains(userEmailAddress) && $0.requestedIsDecrypted == false
                    }) { req in
                      HStack {
                        RequestsAppDetails(bundleId: req.requestedId)
                        Spacer()
                        Button {
                          withAnimation {
                            removeRequestFromQueue(bundleId: req.requestedId)
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
                } else {
                  Text("A true fully automatic decryption service in your hands!")
                    .font(.headline.bold())
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
                    }
                    else if (requests.filter {
                      $0.requestersEmail.contains(userEmailAddress) && $0.requestedIsDecrypted == false
                    }.count) >= userReqLimit && resultMessage != .isReady {
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
                        Text(resultMessage.rawValue)
                        if !serviceIsOn && (resultMessage != .isReady && resultMessage != .isBlocked) {
                          Label("The process of decryption may be temporarily delayed due to a high volume of demand.",
                                systemImage: "exclamationmark.triangle.fill")
                          .font(.caption)
                          .foregroundColor(.red)
                          .padding(.top, 1)
                        }
                        if resultMessage == .isReady {
                          HStack {
                            Button {
                              UIPasteboard.general.string = readyLink
                              withAnimation {
                                linkCopied = true
                              }
                            } label: {
                              HStack(spacing: 10) {
                                Image(systemName: linkCopied ? "checkmark.circle.fill" : "doc.on.doc.fill")
                                Text(linkCopied ? "Download Link Copied to Clipboard" : "Click to Copy Download Link to Clipboard")
                              }
                              .font(.footnote)
                              .frame(minWidth: geo.size.width * (7.4/10))
                            }
                            .softButtonStyle(
                              RoundedRectangle(cornerRadius: 10),
                              pressedEffect: .flat
                            )
                            .disabled(linkCopied)
                          }
                          .padding(.top)
                          .onChange(of: linkCopied) { bool in
                            if bool {
                              Task {
                                try? await Task.sleep(nanoseconds: 4000000000)
                                withAnimation {
                                  linkCopied = false
                                }
                              }
                            }
                          }
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
                          }
                          if let data = lookedup?.results[0] {
                            if theBlacklist.contains(data.bundleId) {
                              resultMessage = .isBlocked
                            } else {
                              await doRequest(bundleId: data.bundleId, version: data.version)
                            }
                            withAnimation {
                              requestSubmitted = true
                            }
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
                      .disabled(requestProgress || requestSubmitted || (requests.filter {
                        $0.requestersEmail.contains(userEmailAddress) && $0.requestedIsDecrypted == false
                      }.count) >= userReqLimit)
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
    }
  }

  // MARK: -
  func removeRequestFromQueue(bundleId: String) {
    let realm = requests.realm!.thaw()
    let thawedReqs = requests.thaw()!
    let request = thawedReqs.where {
      $0.requestedId.contains(bundleId) && $0.requestersEmail.contains(userEmailAddress)
    }
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
      newStat.lookedId = bundleId
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
  func doRequest(bundleId: String, version: String) async {
    let newReq = deReq()
    do {
      serviceIsOn = try checkStatusCode(url: "https://run.decryptkit.xyz/status", statusCode: 200)
    } catch {
      serviceIsOn = false
    }
    let realm = requests.realm!.thaw()
    let thawedReqs = requests.thaw()!
    let request = thawedReqs.where {
      $0.requestedId.contains(bundleId)
    }
    if request.isEmpty {
      debugPrint("Appending request for \(bundleId) to deReq")
      newReq.requestedId = bundleId
      newReq.requestedVersion = version
      newReq.requestersEmail.append(userEmailAddress)
      newReq.requestedDate = Date()
      newReq.requestedIsDecrypted = false
      newReq.requestedDecryptedLink = ""
      $requests.append(newReq)
      resultMessage = .beenAdded
    } else {
      let reqToUpdate = request[0]
      if reqToUpdate.requestedIsDecrypted {
        var fileIs404 = false
        do {
          fileIs404 = try checkStatusCode(url: reqToUpdate.requestedDecryptedLink, statusCode: 404)
        } catch {
          fileIs404 = true
        }
        if !fileIs404 && reqToUpdate.requestedVersion == version {
          readyLink = reqToUpdate.requestedDecryptedLink
          resultMessage = .isReady
        } else if fileIs404 || reqToUpdate.requestedVersion != version {
          try! realm.write {
            reqToUpdate.requestedVersion = version
            reqToUpdate.requestedDate = Date()
            reqToUpdate.requestedIsDecrypted = false
            reqToUpdate.requestedDecryptedLink = ""
          }
        }
        if !reqToUpdate.requestersEmail.contains(userEmailAddress) {
          debugPrint("Appending \(userEmailAddress) to requests for \(bundleId)")
          try! realm.write {
            reqToUpdate.requestersEmail.append(userEmailAddress)
          }
        }
      } else {
        if reqToUpdate.requestersEmail.contains(userEmailAddress) {
          debugPrint("\(userEmailAddress) already requested \(bundleId)")
          resultMessage = .inQueue
        } else {
          debugPrint("Appending \(userEmailAddress) to requests for \(bundleId)")
          try! realm.write {
            reqToUpdate.requestersEmail.append(userEmailAddress)
          }
          resultMessage = .beenAdded
        }
        if reqToUpdate.requestedVersion != version {
          try! realm.write {
            reqToUpdate.requestedVersion = version
            reqToUpdate.requestedDate = Date()
          }
        }
      }
    }
  }

}
