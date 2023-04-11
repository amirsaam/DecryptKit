//
//  UtilityFuncs.swift
//  deCripple
//
//  Created by Amir Mohammadi on 9/3/1401 AP.
//

import Foundation

func checkStatusCode(url: String, statusCode: Int) throws -> Bool {
  guard let url = URL(string: url) else { fatalError("Status check URL is invalid!") }
  
  let semaphore = DispatchSemaphore(value: 0)
  var result = false
  var throwError: Error?
  var request = URLRequest(url: url)
  request.httpMethod = "HEAD"
  
  URLSession.shared.dataTask(with: request) { _, response, error in
    defer { semaphore.signal() }
    if let error = error {
      debugPrint(error.localizedDescription)
      throwError = error
    }
    if let httpResponse = response as? HTTPURLResponse {
      result = httpResponse.statusCode == statusCode
    }
  }.resume()

  semaphore.wait()
  if let error = throwError {
    throw error
  } else {
    return result
  }
}

enum deResult: String, CaseIterable {
   case null = ""
   case beenAdded = "Your request has been added to queue"
   case inQueue = "Your request is already in queue"
   case isReady = "Your request is ready to download"
 }
