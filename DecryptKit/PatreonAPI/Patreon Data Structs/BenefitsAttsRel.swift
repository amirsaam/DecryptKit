//
//  BenefitsAttsRel.swift
//  DecryptKit
//
//  Created by Amir Mohammadi on 11/11/1401 AP.
//

import Foundation

struct CampaignBenefit: Codable {
  let attributes: CampaignBenefitAttributes
  let relationships: CampaignBenefitRelationships
  
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
  
  struct CampaignBenefitRelationships: Codable {
    let campaign: PatreonCampaignInfo
    // let campaign_installation: CampaignInstallation?
    let deliverables: [CampaignDeliverable]
    let tiers: [CampaignTier]
  }
}
