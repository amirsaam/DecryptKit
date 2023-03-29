//
//  ViewModels.swift
//  DecryptKit
//
//  Created by Amir Mohammadi on 11/9/1401 AP.
//

import Foundation
import PatreonAPI

// MARK: - Patreon Client Data
struct PatreonClient {
  public static let shared = PatreonClient()
  
  let clientID = "MKzRZxagIOea-ceFt_54sjf9yyA2TzTHln9LiUoybU8ZRg7ljS4KE9HrBPa9i6aA"
  let clientSecret = "4kTPw037oTE6D9zGHDwBgxqljtd70UkLBXAA25lIk83ZRbrlQjNr3sN8-TFa8dI6"
  let creatorAccessToken = "f28mTaS7tddZRu3wNHDEJjbqemg_2gS2XLbgB8RoOxo"
  let creatorRefreshToken = "6YQIsyM1SYgD0NQfV_sPXi15VnaqDqvdfssX1tKacJs"
  let redirectURI = "https://decryptkit.xyz/patreon/6NvbE37T33cKTmpu1DkAtvuEK4XdWzF"
  let campaignID = "9760149"
}

// MARK: - User's Data VM
class UserVM: ObservableObject {
  public static let shared = UserVM()

  @Published var userId: String = ""
  @Published var userUID: String = ""
  @Published var userIsBanned: Bool = false
  @Published var userEmail: String = ""
  @Published var userTier: Int = 0
  @Published var userPAT: String = ""
  @Published var userPRT: String = ""
}

// MARK: - Source's Data VM
class SourceVM: ObservableObject {
  public static let shared = SourceVM()
  
  @Published var freeSourceData: [deCrippleSource]? = nil
  @Published var vipSourceData: [deCrippleSource]? = nil
}

// MARK: - Patreon's Data VM
class PatreonVM: ObservableObject {
  public static let shared = PatreonVM()
  
  @Published var patronTokensFetched: Bool = false
  @Published var patreonOAuth: PatronOAuth? = nil
  @Published var patronMembership: [UserIdentityIncludedMembership] = []
  @Published var patronIdentity: PatreonUserIdentity? {
    didSet {
      if let identity = patronIdentity {
        patronMembership = extractUserMembership(from: identity.included)
      } else {
        patronMembership = []
      }
    }
  }
  @Published var campaignTiers: [CampaignIncludedTier] = []
  @Published var campaignBenefits: [CampaignIncludedBenefit] = []
  @Published var patreonCampaign: PatreonCampaignInfo? {
    didSet {
      if let campaign = patreonCampaign {
        campaignTiers = extractCampaignTiers(from: campaign.included)
        campaignBenefits = extractCampaignBenefits(from: campaign.included)
      } else {
        campaignTiers = []
        campaignBenefits = []
      }
    }
  }
  
  func extractUserMembership(from identity: [UserIdentityIncludedAny]) -> [UserIdentityIncludedMembership] {
    var decodedArray = [UserIdentityIncludedMembership]()
    for identityIncluded in identity {
      if identityIncluded.type == "member" {
        let decoded = try? JSONDecoder().decode(UserIdentityIncludedMembership.self, from: try JSONEncoder().encode(identityIncluded))
        if let decoded = decoded {
          decodedArray.append(decoded)
        }
      }
    }
    return decodedArray
  }

  func extractCampaignTiers(from campaign: [CampaignIncludedAny]) -> [CampaignIncludedTier] {
    var decodedArray = [CampaignIncludedTier]()
    for campaignIncluded in campaign {
      if campaignIncluded.type == "tier" {
        let decoded = try? JSONDecoder().decode(CampaignIncludedTier.self, from: try JSONEncoder().encode(campaignIncluded))
        if let decoded = decoded {
          decodedArray.append(decoded)
        }
      }
    }
    return decodedArray
  }
  
  func extractCampaignBenefits(from campaign: [CampaignIncludedAny]) -> [CampaignIncludedBenefit] {
    var decodedArray = [CampaignIncludedBenefit]()
    for campaignIncluded in campaign {
      if campaignIncluded.type == "benefit" {
        let decoded = try? JSONDecoder().decode(CampaignIncludedBenefit.self, from: try JSONEncoder().encode(campaignIncluded))
        if let decoded = decoded {
          decodedArray.append(decoded)
        }
      }
    }
    return decodedArray
  }
}
