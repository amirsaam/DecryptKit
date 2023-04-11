//
//  SourceData.swift
//  deCripple
//
//  Created by Amir Mohammadi on 9/16/1401 AP.
//

import Foundation

// MARK: - Source Structure
struct deCrippleSource: Codable, Hashable {
  var bundleID: String
  var name: String
  var version: String
  var itunesLookup: String
  var link: String
}

// MARK: - Sources
enum SourcesURLs: String, CaseIterable {
  case free = "https://amrsm.ir/decrypted.json"
  case vip = "https://amrsm.ir/vip.json"
}

// MARK: - Get Live Source Data
func getSourceData(source: SourcesURLs) async -> [deCrippleSource]? {
  guard let url = URL(string: source.rawValue) else { return nil }
  do {
    let (data, _) = try await URLSession.shared.data(
      for: URLRequest(url: url, cachePolicy: .reloadIgnoringLocalAndRemoteCacheData)
    )
    let decoder = JSONDecoder()
    let jsonResult: [deCrippleSource] = try decoder.decode([deCrippleSource].self, from: data)
    return jsonResult
  } catch {
    debugPrint("Error getting Result data from a source URL.")
  }
  return nil
}

// MARK: - Get & Cache Source Data
func resolveSourceData() async {
  let refreshedFreeSourceData: [deCrippleSource]? = await getSourceData(source: .free)
  debugPrint("FreeSourceData Refreshed")
  SourceVM.shared.freeSourceData = refreshedFreeSourceData
  if let freeData = refreshedFreeSourceData {
    freeData.forEach { app in
      if !outAppStoreBundleID.contains(app.bundleID) {
        resolveLookupData(app.bundleID)
      }
    }
  }
  let refreshedVIPSourceData: [deCrippleSource]? = await getSourceData(source: .vip)
  debugPrint("VIPSourceData Refreshed")
  SourceVM.shared.vipSourceData = refreshedVIPSourceData
  if let vipData = refreshedVIPSourceData {
    vipData.forEach { app in
      if !outAppStoreBundleID.contains(app.bundleID) {
        resolveLookupData(app.bundleID)
      }
    }
  }
}
