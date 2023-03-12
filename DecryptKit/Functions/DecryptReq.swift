//
//  DecryptReq.swift
//  deCripple
//
//  Created by Amir Mohammadi on 9/3/1401 AP.
//

import Foundation

enum deResult: String, CaseIterable {
  case null = ""
  case beenAdded = "Your request has been added to queue"
  case inQueue = "Your request is already in queue"
  case isReady = "Your request is ready to download"
}

func isServiceRunning() async -> Bool {
  guard let url = URL(string: "https://run.decryptkit.xyz") else {
    fatalError("Status check URL is invalid!")
  }
  do {
    let (_, response) = try await URLSession.shared.data(from: url)
    return (response as? HTTPURLResponse)?.statusCode == 200
  } catch {
    debugPrint("Decryption Service is Unreachable!")
    return false
  }
}

/*
func reqDecrypt(_ id: String, _ email: String) async -> deCrippleResult? {

  var urlComponents = URLComponents()

  urlComponents.scheme = "https"
  urlComponents.host = "run.decryptkit.xyz"
  urlComponents.path = "/decrypt"
  urlComponents.queryItems = [
        URLQueryItem(name: "bundleID", value: id),
        URLQueryItem(name: "email", value: email)
      ]

  guard let url = urlComponents.url else { return nil }
  debugPrint(url)

  do {
    let (data, _) = try await URLSession.shared.data(for: URLRequest(url: url))
    let decoder = JSONDecoder()
    let jsonResult: deCrippleResult = try decoder.decode(deCrippleResult.self, from: data)
    return jsonResult
  } catch {
    debugPrint("Error getting Result data from URL: \(url): \(error)")
  }
  return nil
}
*/
