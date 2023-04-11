//
//  iTunesLookup.swift
//  deCripple
//
//  Created by Amir Mohammadi on 9/1/1401 AP.
//

import Foundation
import DataCache

// MARK: - iTunes Lookup Structure
struct ITunesResponse: Codable {
  let resultCount: Int
  let results: [ITunesResult]
}

struct ITunesResult: Codable {
  let isGameCenterEnabled: Bool
  let features: [String]
  let advisories: [String]
  let supportedDevices: [String]
  let screenshotUrls: [String]
  let ipadScreenshotUrls: [String]
  let appletvScreenshotUrls: [String]
  let artworkUrl60: String
  let artworkUrl512: String
  let artworkUrl100: String
  let artistViewUrl: String
  let kind: String
  let artistId: Int
  let artistName: String
  let genres: [String]
  let price: Float
  let releaseNotes: String?
  let description: String
  let isVppDeviceBasedLicensingEnabled: Bool
  let primaryGenreName: String
  let primaryGenreId: Int
  let bundleId: String
  let genreIds: [String]
  let currency: String
  let releaseDate: String
  let sellerName: String
  let trackId: Int
  let trackName: String
  let currentVersionReleaseDate: String
  let averageUserRating: Float
  let averageUserRatingForCurrentVersion: Float?
  let trackViewUrl: String?
  let trackContentRating: String?
  let minimumOsVersion: String
  let trackCensoredName: String
  let languageCodesISO2A: [String]
  let fileSizeBytes: String
  let sellerUrl: String?
  let formattedPrice: String
  let contentAdvisoryRating: String
  let userRatingCountForCurrentVersion: Int
  let version: String
  let wrapperType: String
  let userRatingCount: Int
}

// MARK: - Get Live iTunes Lookup
func getITunesData(_ id: String) async -> ITunesResponse? {
  var urlComponents = URLComponents()
  urlComponents.scheme = "https"
  urlComponents.host = "itunes.apple.com"
  urlComponents.path = "/lookup"
  urlComponents.queryItems = id.isNumber
    ? [URLQueryItem(name: "id", value: id)]
    : [URLQueryItem(name: "bundleId", value: id)]
  guard let url = urlComponents.url else { return nil }
  do {
    let (data, _) = try await URLSession.shared.data(
      for: URLRequest(url: url, cachePolicy: .reloadIgnoringLocalAndRemoteCacheData)
    )
    let decoder = JSONDecoder()
    let jsonResult: ITunesResponse = try decoder.decode(ITunesResponse.self, from: data)
    if jsonResult.resultCount > 0 {
      debugPrint("iTunesLookup: Valid file from \(url) fetched.")
      return jsonResult
    } else {
      debugPrint("iTunesLookup: File from \(url) is empty or not valid.")
    }
  } catch {
    debugPrint("Error getting iTunes data from URL: \(url): \(error)")
  }
  return nil
}

// MARK: - Get & Cache iTunes Lookup
func resolveLookupData(_ id: String) {
  Task {
    if let refreshedLookupData: ITunesResponse = await getITunesData(id) {
      cache.clean(byKey: id)
      try? cache.write(codable: refreshedLookupData, forKey: id)
    }
  }
}
