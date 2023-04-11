//
//  PatreonVM.swift
//  deCripple
//
//  Created by Amir Mohammadi on 1/20/1402 AP.
//

import Foundation
import PatreonAPI

// MARK: - Patreon's Data VM
class PatreonVM: ObservableObject {
  public static let shared = PatreonVM()

  @Published var patronTokensFetched = false
  @Published var patreonOAuth: PatronOAuth?
  @Published var patronMembership: [UserIdentityIncludedMembership] = [] {
    didSet {
      identifyPatronTier()
    }
  }
  @Published var patronIdentity: PatreonUserIdentity? {
    didSet {
      if let identity = patronIdentity {
        patronMembership = extractUserMembership(from: identity.included)
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
      }
    }
  }
  @Published var userIsPatron = false
  @Published var userSubscribedTierId = "Not Subscribed"

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

  func identifyPatronTier() {
    campaignTiers.forEach { tier in
      if !userIsPatron {
        userIsPatron = patronMembership.contains { data in
          data.relationships.currently_entitled_tiers.data.contains { entitledTier in
            userSubscribedTierId = entitledTier.id == tier.id ? tier.id : "Not Subscribed"
            return entitledTier.id == tier.id
          }
        }
      }
    }
  }

}
