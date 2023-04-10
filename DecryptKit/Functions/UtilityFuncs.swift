//
//  UtilityFuncs.swift
//  deCripple
//
//  Created by Amir Mohammadi on 9/3/1401 AP.
//

import Foundation

func checkStatusCode(url: String, statusCode: Int) -> Bool {
  guard let url = URL(string: url) else { fatalError("Status check URL is invalid!") }

  let semaphore = DispatchSemaphore(value: 0)
  var result = false
  var request = URLRequest(url: url)
  request.httpMethod = "HEAD"
  
  URLSession.shared.dataTask(with: request) { _, response, error in
    defer { semaphore.signal() }
    if let error = error {
      debugPrint(error.localizedDescription)
    } else {
      if let httpResponse = response as? HTTPURLResponse {
        result = httpResponse.statusCode == statusCode
      }
    }
  }.resume()

  semaphore.wait()
  return result
}
