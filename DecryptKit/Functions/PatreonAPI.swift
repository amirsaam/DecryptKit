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
}

class Patreon {
  let client = PatreonClient()
  let redirectURL = "deCripple://patreon?"
  
  func oauth() {
    
  }
}
