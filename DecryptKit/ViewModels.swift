//
//  ViewModels.swift
//  DecryptKit
//
//  Created by Amir Mohammadi on 11/9/1401 AP.
//

import Foundation

class UserVM: ObservableObject {
  public static let shared = UserVM()

  var userId: String = ""
  var userUID: String = ""
  var userIsBanned: Bool = false
  var userEmail: String = ""
  var userTier: Int = 0
  var userPAT: String = ""
  var userPRT: String = ""
}

class SourceVM: ObservableObject {
  public static let shared = SourceVM()
  
  var freeSourceData: [deCrippleSource]? = nil
  var vipSourceData: [deCrippleSource]? = nil
}

class PatreonVM: ObservableObject {
  public static let shared = PatreonVM()
  
  var tokensFetched: Bool = false
  var patreonCampaign: PatreonCampaignInfo? = nil
  var patreonOAuth: PatronOAuth? = nil
  var patronIdentity: PatronIdentity? = nil
}
