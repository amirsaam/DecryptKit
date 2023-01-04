//
//  SourceData.swift
//  DecryptKit
//
//  Created by Amir Mohammadi on 9/16/1401 AP.
//

import Foundation
import DataCache

struct deCrippleSource: Codable {
  var bundleID: String
  var name: String
  var version: String
  var itunesLookup: String
  var link: String
}

func getSourceData() async -> [deCrippleSource]? {
  
  guard let url = URL(string: "https://amrsm.ir/decrypted.json") else { return nil }

  do {
    let (data, _) = try await URLSession.shared.data(for: URLRequest(url: url))
    let decoder = JSONDecoder()
    let jsonResult: [deCrippleSource] = try decoder.decode([deCrippleSource].self, from: data)
    debugPrint("SourceData Fetched")
    return jsonResult
  } catch {
    print("Error getting Result data from URL: \(url): \(error)")
  }

  return nil
}

func resolveSourceData() async {
  let refreshedSourceData: [deCrippleSource]? = await getSourceData()
  try? cache.write(codable: refreshedSourceData, forKey: "cachedSourceData")
  debugPrint("SourceData Refreshed")
  if let data = refreshedSourceData {
    data.forEach { app in
      if !outAppStoreBundleID.contains(app.bundleID) {
        resolveLookupData(app.bundleID)
      }
    }
  }
}
