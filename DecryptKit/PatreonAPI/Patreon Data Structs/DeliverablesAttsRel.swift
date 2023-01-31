//
//  DeliverablesAttsRel.swift
//  DecryptKit
//
//  Created by Amir Mohammadi on 11/11/1401 AP.
//

import Foundation

struct CampaignDeliverable: Codable {
  let attributes: CampaignDeliverableAttributes
  let relationships: CampaignDeliverableRelationships
  
  struct CampaignDeliverableAttributes: Codable {
    let completed_at: String
    let delivery_status: String
    let due_at: String
  }
  
  struct CampaignDeliverableRelationships: Codable {
    let benefit: CampaignBenefit
    let campaign: PatreonCampaignInfo
    let member: String
    let user: String
  }
}
