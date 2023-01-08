//
//  PatreonAPI.swift
//  DecryptKit
//
//  Created by Amir Mohammadi on 10/11/1401 AP.
//

import Foundation

struct PatreonClient {
  let clientID = "MKzRZxagIOea-ceFt_54sjf9yyA2TzTHln9LiUoybU8ZRg7ljS4KE9HrBPa9i6aA"
  let clientSecret = "4kTPw037oTE6D9zGHDwBgxqljtd70UkLBXAA25lIk83ZRbrlQjNr3sN8-TFa8dI6"
  let creatorAccessToken = "3YVSAbYWvmtWCEmVItQaXjZGyHqYgGy8_w4mVV_47h4"
  let creatorRefreshToken = "NjmDj3mZ1b5ae7zcNKZD6cmZRtfsEdddCnRvaywliL4"
  let campaignID = "9760149"
  let redirectURL = "deCripple://patreon?"
  let redirectURI = "https://decryptkit.xyz/patreon/"
}

struct PatronOAuth {
  let access_token: String
  let refresh_token: String
  let expires_in: String
  let scope: String
  let token_type: String
}

class Patreon {
  let client = PatreonClient()
  
  func oauth() async {
    var urlComponents = URLComponents()

    urlComponents.scheme = "https"
    urlComponents.host = "www.patreon.com"
    urlComponents.path = "oauth2/authorize"
    urlComponents.queryItems = [
      URLQueryItem(name: "response_type", value: "code"),
      URLQueryItem(name: "client_id", value: client.clientID),
      URLQueryItem(name: "redirect_uri", value: client.redirectURL)
    ]

    guard let url = urlComponents.url else { return }
    debugPrint(url)
  }
}
