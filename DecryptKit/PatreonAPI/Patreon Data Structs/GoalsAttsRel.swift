//
//  GoalsAttsRel.swift
//  DecryptKit
//
//  Created by Amir Mohammadi on 11/11/1401 AP.
//

import Foundation

struct CampaignGoal: Codable {
  let attributes: CampaignGoalAttributes
  let relationships: CampaignGoalRelationships
  
  struct CampaignGoalAttributes: Codable {
    let amount_cents: Int
    let completed_percentage: Int
    let created_at: String
    let description: String?
    let reached_at: String?
    let title: String
  }
  
  struct CampaignGoalRelationships: Codable {
    let campaign: PatreonCampaignInfo
  }
}
