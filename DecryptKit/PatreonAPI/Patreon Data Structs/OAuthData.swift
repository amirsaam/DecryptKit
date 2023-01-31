//
//  OAuthData.swift
//  DecryptKit
//
//  Created by Amir Mohammadi on 11/11/1401 AP.
//

import Foundation

struct PatronOAuth: Codable {
  let access_token: String
  let refresh_token: String
  let expires_in: Int
  let scope: String
  let token_type: String
}
