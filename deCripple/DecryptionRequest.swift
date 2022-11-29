//
//  DecryptionRequest.swift
//  deCripple
//
//  Created by Amir Mohammadi on 9/3/1401 AP.
//

import Foundation

struct deCrippleResult: Codable {
  var result: Int
  var proximity: String
}

//func reqDecrypt(_ id: String, _ email: String, _ promo: String) async -> deCrippleResult? {
func reqDecrypt(_ id: String, _ email: String) async -> deCrippleResult? {

  var urlComponents = URLComponents()
  urlComponents.scheme = "https"
  urlComponents.host = "decripple.tech"
  urlComponents.path = "/decrypt"
  urlComponents.queryItems = [
    //    URLQueryItem(name: "service", value: "decripple"),
        URLQueryItem(name: "bundleID", value: id),
        URLQueryItem(name: "email", value: email)
    //    URLQueryItem(name: "promo", value: promo)
      ]
  guard let url = urlComponents.url else { return nil }
  print("\(url)")

  do {
    let (data, _) = try await URLSession.shared.data(for: URLRequest(url: url))
    let decoder = JSONDecoder()
    let jsonResult: deCrippleResult = try decoder.decode(deCrippleResult.self, from: data)
    return jsonResult
  } catch {
    print("Error getting Result data from URL: \(url): \(error)")
  }

  return nil
}

struct deCrippleSource: Codable {
  var bundleID: String
  var name: String
  var version: String
  var itunesLookup: String
  var link: String
}

func getSourceData() async -> [deCrippleSource]? {
  
  guard let url = URL(string: "https://repo.amrsm.ir/ZGVjcnlwdGVkLmpzb24=") else { return nil }

  do {
    let (data, _) = try await URLSession.shared.data(for: URLRequest(url: url))
    let decoder = JSONDecoder()
    let jsonResult: [deCrippleSource] = try decoder.decode([deCrippleSource].self, from: data)
    return jsonResult
  } catch {
    print("Error getting Result data from URL: \(url): \(error)")
  }

  return nil
}
