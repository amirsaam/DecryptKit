//
//  PatreonOAuth.swift
//  DecryptKit
//
//  Created by Amir Mohammadi on 11/10/1401 AP.
//

import Foundation
import Alamofire
import Semaphore
import SwiftUI

// MARK: - Patreon OAuth Calls
extension PatreonAPI {

  // 1st OAuth Call
  func doOAuth() {
    var urlComponents = URLComponents()
    urlComponents.scheme = "https"
    urlComponents.host = "www.patreon.com"
    urlComponents.path = "/oauth2/authorize"
    urlComponents.queryItems = [
      URLQueryItem(name: "response_type", value: "code"),
      URLQueryItem(name: "client_id", value: client.clientID),
      URLQueryItem(name: "redirect_uri", value: client.redirectURI)
    ]
    guard let url = urlComponents.url else { return }
    UIApplication.shared.open(url)
  }

  // Get User Tokens
  func getOAuthTokens(_ code: String) async -> PatronOAuth? {
    let params: [String: String] = ["code": code,
                                    "grant_type": "authorization_code",
                                    "client_id": client.clientID,
                                    "client_secret": client.clientSecret,
                                    "redirect_uri": client.redirectURI]
    return await fetchOAuthResponse(params)
  }

  // Refresh User Tokens
  func refreshOAuthTokens(_ refreshToken: String) async -> PatronOAuth? {
    let params: [String: String] = ["grant_type": "refresh_token",
                                    "refresh_token": refreshToken,
                                    "client_id": client.clientID,
                                    "client_secret": client.clientSecret]
    return await fetchOAuthResponse(params)
  }

  // Fetch Tokens Fucntion
  private func fetchOAuthResponse(
    _ params: Dictionary<String, String>
  ) async -> PatronOAuth? {

    let semaphore = AsyncSemaphore(value: 0)
    var requestResponse: PatronOAuth?
  
    guard let url = URL(string: "https://www.patreon.com/api/oauth2/token") else { return nil }
    let headers: HTTPHeaders = ["Content-Type": "application/x-www-form-urlencoded"]

    alamofire.request(url,
                      method: .post,
                      parameters: params,
                      headers: headers)
    .responseDecodable(of: PatronOAuth.self) {
      (response: DataResponse<PatronOAuth, AFError>) in
      switch response.result {
      case .success(let data):
        requestResponse = data
      case .failure(let error):
        debugPrint(error)
        requestResponse = nil
      }
      semaphore.signal()
    }

    await semaphore.wait()
    return requestResponse
  }

}
