//
//  CampaignData.swift
//  DecryptKit
//
//  Created by Amir Mohammadi on 11/11/1401 AP.
//

import Foundation

// MARK: - Campaigns owned by a User
struct PatronOwnedCampaigns: Codable {
  let data: [CampaignData]
  let meta: Meta

  struct Meta: Codable {
    let pagination: Pagination
    struct Pagination: Codable {
      let total: Int
    }
  }
}

// MARK: - Specific Campaign Details
struct PatreonCampaignInfo: Codable {
  let data: CampaignData
  let included: [CampaignIncludedAny]
  let links: SelfLink
}

// MARK: - Campaign General Details
struct CampaignData: Codable {
  let attributes: CampaignAttributes
  let id: String
  let relationships: CampaignRelationships
  let type: String
  
  struct CampaignAttributes: Codable {
    let created_at: String
    let creation_name: String?
    let discord_server_id: String?
    let google_analytics_id: String?
    let has_rss: Bool
    let has_sent_rss_notify: Bool
    let image_small_url: String
    let image_url: String
    let is_charged_immediately: Bool?
    let is_monthly: Bool
    let is_nsfw: Bool
    let main_video_embed: String?
    let main_video_url: String?
    let one_liner: String?
    let patron_count: Int
    let pay_per_name: String?
    let pledge_url: String
    let published_at: String?
    let summary: String?
    let thanks_embed: String?
    let thanks_msg: String?
    let thanks_video_url: String?
    let url: String
    let vanity: String?
  }
  
  struct CampaignRelationships: Codable {
    let benefits: IdTypeArray?
    let creator: Creator
    let goals: IdTypeArray?
    let tiers: IdTypeArray?
  }
  
  struct Creator: Codable {
    let data: IdTypePlain?
    let links: Links
    
    struct Links: Codable {
      let related: String
    }
  }
}

// MARK: Campaign Included Data

/// Used to retrive both `CampaignIncludedTier` and `CampaignIncludedBenefit` at the same time.
struct CampaignIncludedAny: Codable {
  var attributes: [String: AnyCodable]
  let id: String
  let type: String
}

/// For decoding `CampaignIncludedAny` based on `type == "tier"`
struct CampaignIncludedTier: Codable {
  var attributes: CampaignTierAttributes
  let id: String
  let type: String
  
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
}

/// For decoding `CampaignIncludedAny` based on `type == "benefit"`
struct CampaignIncludedBenefit: Codable {
  var attributes: CampaignBenefitAttributes
  let id: String
  let type: String
  
  struct CampaignBenefitAttributes: Codable {
    let app_external_id: String?
    let app_meta: [String: String]?
    let benefit_type: String?
    let created_at: String
    let deliverables_due_today_count: Int
    let delivered_deliverables_count: Int
    let description: String?
    let is_deleted: Bool
    let is_ended: Bool
    let is_published: Bool
    let next_deliverable_due_date: String?
    let not_delivered_deliverables_count: Int
    let rule_type: String?
    let tiers_count: Int
    let title: String
  }
}
