//
//  PatreonAPI.swift
//  deCripple
//
//  Created by Amir Mohammadi on 10/11/1401 AP.
//

import Foundation
import SwiftUI
import Alamofire
import Semaphore

// MARK: - Patreon Client Details
struct PatreonClient {
  let clientID = "MKzRZxagIOea-ceFt_54sjf9yyA2TzTHln9LiUoybU8ZRg7ljS4KE9HrBPa9i6aA"
  let clientSecret = "4kTPw037oTE6D9zGHDwBgxqljtd70UkLBXAA25lIk83ZRbrlQjNr3sN8-TFa8dI6"
  let creatorAccessToken = "mfN-03GqFy6AiE7Jzq-I7CEdWuXfHMg_2VlLO0kcMgE"
  let creatorRefreshToken = "rnz8ny-qw8kdVM3bFyL27fssb1jRqta11WARXfPUm_Q"
  let redirectURI = "https://decryptkit.xyz/patreon/6NvbE37T33cKTmpu1DkAtvuEK4XdWzF"
  let campaignID = "9760149"
}

// MARK: - Patreon Class
class PatreonAPI {
  let client = PatreonClient()
  public static let shared = PatreonAPI()
}
