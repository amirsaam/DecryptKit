//
//  TiersAttsRel.swift
//  DecryptKit
//
//  Created by Amir Mohammadi on 11/11/1401 AP.
//

import Foundation

struct CampaignTier: Codable {
  let attributes: CampaignTierAttributes
  let relationships: CampaignTierRelationships
  
  struct CampaignTierAttributes: Codable {
    let amount_cents: Int
    let created_at: String
    let description: String?
    let discord_role_ids: [String: String]?
    let edited_at: String
    let image_url: String?
    let patron_count: Int
    let post_count: Int?
    let published: Bool
    let published_at: String?
    let remaining: Int?
    let requires_shipping: Bool
    let title: String
    let unpublished_at: String?
    let url: String
    let user_limit: Int?
  }
  
  struct CampaignTierRelationships: Codable {
    let benefits: [CampaignBenefit]
    let campaign: PatreonCampaignInfo
    let tier_image: PatreonMedia
  }
}
