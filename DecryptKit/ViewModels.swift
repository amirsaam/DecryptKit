//
//  ViewModels.swift
//  DecryptKit
//
//  Created by Amir Mohammadi on 11/9/1401 AP.
//

import Foundation
import PatreonAPI

// MARK: - User's Data VM
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

// MARK: - Source's Data VM
class SourceVM: ObservableObject {
  public static let shared = SourceVM()
  
  var freeSourceData: [deCrippleSource]? = nil
  var vipSourceData: [deCrippleSource]? = nil
}

// MARK: - Patreon's Data VM
class PatreonVM: ObservableObject {
  public static let shared = PatreonVM()
  
  var tokensFetched: Bool = false
  var patreonOAuth: PatronOAuth? = nil
  var patronIdentity: PatreonUserIdentity? = nil
  var campaignTiers: [CampaignIncludedTier] = []
  var campaignBenefits: [CampaignIncludedBenefit] = []
  var patreonCampaign: PatreonCampaignInfo? {
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
