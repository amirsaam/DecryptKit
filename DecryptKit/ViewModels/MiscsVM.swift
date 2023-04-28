//
//  MiscsVM.swift
//  deCripple
//
//  Created by Amir Mohammadi on 11/9/1401 AP.
//

import Foundation

// MARK: -
class UpdaterVM: ObservableObject {
  public static let shared = UpdaterVM()

  private let appVersion = "1.0.0"
  private var upstreamData: VersionData? {
    didSet {
      if let data = upstreamData {
        upstreamVersion = data.version
        upstreamIsCritical = data.isCritical
        appIsUpToDate = data.version == appVersion
      }
    }
  }
  @Published var upstreamVersion = ""
  @Published var upstreamIsCritical = false
  @Published var appIsUpToDate = false

  func checkUpstream() async {
    guard let url = URL(string: "https://repo.decryptkit.xyz/appversion.json") else { return }
    do {
      let (data, _) = try await URLSession.shared.data(
        for: URLRequest(url: url, cachePolicy: .reloadIgnoringLocalAndRemoteCacheData)
      )
      upstreamData = try JSONDecoder().decode(VersionData.self, from: data)
      debugPrint("Upstream app version data retrieved.")
    } catch {
      debugPrint("Error getting Result data from URL: \(url): \(error)")
    }
  }

  internal struct VersionData: Codable {
    let version: String
    let isCritical: Bool
  }
}

// MARK: - User's Data VM
class UserVM: ObservableObject {
  public static let shared = UserVM()

  @Published var userId = ""
  @Published var userUID = ""
  @Published var userIsBanned = false
  @Published var userEmail = ""
  @Published var userTier = 0 {
    didSet {
      userReqLimit = userTier == 0 ? 1 : userTier < 3 ? 3 : userTier == 3 ? 5 : .max
    }
  }
  @Published var userPAT = ""
  @Published var userPRT = ""
  @Published var userReqLimit = 1
}

// MARK: - Source's Data VM
class SourceVM: ObservableObject {
  public static let shared = SourceVM()
  
  @Published var freeSourceData: [deCrippleSource]?
  @Published var vipSourceData: [deCrippleSource]?
  @Published var theBlacklistData: [String] = []
}
