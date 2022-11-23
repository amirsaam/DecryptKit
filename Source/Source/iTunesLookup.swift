//
//  iTunesLookup.swift
//  Source
//
//  Created by Amir Mohammadi on 9/1/1401 AP.
//

import Foundation

struct ITunesResponse: Decodable {
  var resultCount: Int
  var results: [ITunesResult]
}

struct ITunesResult: Decodable {
  var isGameCenterEnabled: Bool
  var supportedDevices: [String]
  var features: [String]
  var advisories: [String]
  var screenshotUrls: [String]
  var ipadScreenshotUrls: [String]
  var appletvScreenshotUrls: [String]
  var artworkUrl60: String
  var artworkUrl512: String
  var artworkUrl100: String
  var artistViewUrl: String
  var kind: String
  var isVppDeviceBasedLicensingEnabled: Bool
  var currentVersionReleaseDate: String
  var releaseNotes: String
  var description: String
  var trackId: Int
  var trackName: String
  var bundleId: String
  var sellerName: String
  var genreIds: [String]
  var primaryGenreName: String
  var primaryGenreId: Int
  var currency: String
  var formattedPrice: String
  var contentAdvisoryRating: String
  var averageUserRatingForCurrentVersion: Float
  var userRatingCountForCurrentVersion: Int
  var trackViewUrl: String
  var trackContentRating: String
  var averageUserRating: Float
  var minimumOsVersion: String
  var trackCensoredName: String
  var languageCodesISO2A: [String]
  var fileSizeBytes: String
  var releaseDate: String
  var artistId: Int
  var artistName: String
  var genres: [String]
  var price: Float
  var version: String
  var wrapperType: String
  var userRatingCount: Int
}

func getITunesData(_ id: String) async -> ITunesResponse? {
  let scheme = "https"
  let host = "itunes.apple.com"
  let path = "/lookup"
  let queryItem = URLQueryItem(name: "id", value: id)
  
  var urlComponents = URLComponents()
  urlComponents.scheme = scheme
  urlComponents.host = host
  urlComponents.path = path
  urlComponents.queryItems = [queryItem]
  guard let url = urlComponents.url else { return nil }
  print("\(url)")

  do {
    let (data, _) = try await URLSession.shared.data(for: URLRequest(url: url))
    let decoder = JSONDecoder()
    let jsonResult: ITunesResponse = try decoder.decode(ITunesResponse.self, from: data)
    if jsonResult.resultCount > 0 {
      return jsonResult
    } else {
      print("resultCount is smaller or equal to 0")
    }
  } catch {
    print("Error getting iTunes data from URL: \(url): \(error)")
  }
  
  return nil
}
