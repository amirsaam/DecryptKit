//
//  PatreonAPI.swift
//  DecryptKit
//
//  Created by Amir Mohammadi on 10/11/1401 AP.
//

import Foundation
import SwiftUI
import Alamofire

struct PatreonClient {
  let clientID = "MKzRZxagIOea-ceFt_54sjf9yyA2TzTHln9LiUoybU8ZRg7ljS4KE9HrBPa9i6aA"
  let clientSecret = "4kTPw037oTE6D9zGHDwBgxqljtd70UkLBXAA25lIk83ZRbrlQjNr3sN8-TFa8dI6"
  let creatorAccessToken = "3YVSAbYWvmtWCEmVItQaXjZGyHqYgGy8_w4mVV_47h4"
  let creatorRefreshToken = "NjmDj3mZ1b5ae7zcNKZD6cmZRtfsEdddCnRvaywliL4"
  let redirectURI = "https://decryptkit.xyz/patreon/6NvbE37T33cKTmpu1DkAtvuEK4XdWzF"
  let campaignID = "9760149"
}

struct PatronOAuth: Codable {
  let access_token: String
  let refresh_token: String
  let expires_in: Int
  let scope: String
  let token_type: String
}

class Patreon {
  let client = PatreonClient()
  let almonfire = AF
  
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
  
  func getOAuthTokens(_ code: String) async -> PatronOAuth? {
    let params: [String: String] = ["code": code,
                                    "grant_type": "authorization_code",
                                    "client_id": client.clientID,
                                    "client_secret": client.clientSecret,
                                    "redirect_uri": client.redirectURI]
    return fetchOAuthResponse(params)
  }
  
  func refreshOAuthTokens(_ refreshToken: String) async -> PatronOAuth? {
    let params: [String: String] = ["grant_type": "refresh_token",
                                    "refresh_token": refreshToken,
                                    "client_id": client.clientID,
                                    "client_secret": client.clientSecret]
    return fetchOAuthResponse(params)
  }
  
  private func fetchOAuthResponse(_ params: Dictionary<String, String>) -> PatronOAuth? {
    var requestResponse: PatronOAuth?
    let semaphore = DispatchSemaphore(value: 0)
    guard let url = URL(string: "https://www.patreon.com/api/oauth2/token") else { return nil }
    let headers: HTTPHeaders = ["Content-Type": "application/x-www-form-urlencoded"]
    almonfire.request(url, method: .post, parameters: params, headers: headers)
      .responseDecodable(of: PatronOAuth.self) { (response: DataResponse<PatronOAuth, AFError>) in
        switch response.result {
        case .success(let data):
          requestResponse = data
        case .failure(let error):
          print(error)
          requestResponse = nil
        }
        semaphore.signal()
      }
    semaphore.wait()
    return requestResponse
  }
}
