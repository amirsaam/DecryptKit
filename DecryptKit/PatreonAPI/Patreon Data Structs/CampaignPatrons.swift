//
//  CampaignPatrons.swift
//  DecryptKit
//
//  Created by Amir Mohammadi on 11/11/1401 AP.
//

import Foundation

// MARK: - Campaign's Patrons List
struct PatreonCampaignMembers: Codable {
  let data: [CampaignMembersData]
  let included: [CampaignMembersIncluded]?
  let meta: CampaignMembersMeta
}

struct CampaignMembersData: Codable {
  let attributes: Attributes
  let id: String
  let relationships: Relationships
  let type: String
  
  struct Attributes: Codable {
    let full_name: String
    let is_follower: Bool
    let last_charge_date: String?
    let last_charge_status: String?
    let lifetime_support_cents: Int
    let currently_entitled_amount_cents: Int
    let patron_status: String?
  }
  
  struct Relationships: Codable {
    let address: IdTypePlain
    let currently_entitled_tiers: IdTypeArray
  }
}
  
struct CampaignMembersIncluded: Codable {
  let attributes: IncludedAttributes
  let id: String
  let type: String
  
  struct IncludedAttributes: Codable {
    let address: AddressAttributes?
    let tier: TierAttributes?
    
    struct AddressAttributes: Codable {
      let addressee: String?
      let city: String?
      let country: String?
      let created_at: String?
      let line_1: String?
      let line_2: String?
      let phone_number: String?
      let postal_code: String?
      let state: String?
    }
    
    struct TierAttributes: Codable {
      let amount_cents: Int?
      let created_at: String?
      let description: String?
      let discord_role_ids: [String]?
      let edited_at: String?
      let patron_count: Int?
      let published: Bool?
      let published_at: String?
      let requires_shipping: Bool?
      let title: String?
      let url: String?
    }
  }
}

struct CampaignMembersMeta: Codable {
  let pagination: Pagination
  
  struct Pagination: Codable {
    let cursors: Cursors
    let total: Int
    
    struct Cursors: Codable {
      let next: String?
    }
  }
}

// MARK: - A Patron's Details
struct PatronFetchedByID: Codable {
  let data: ByPatronIDData
  let included: [ByPatronIDIncluded]
  let links: SelfLink
}

struct ByPatronIDData: Codable {
  let attributes: Attributes
  let id: String
  let relationships: Relationships
  let type: String
  
  struct Attributes: Codable {
    let full_name: String
    let is_follower: Bool
    let last_charge_date: String
  }
  
  struct Relationships: Codable {
    let address: RelationshipData
    let user: RelationshipData
    
    struct RelationshipData: Codable {
      let data: IdType
      let links: RelatedLink
    }
  }
}
  
struct ByPatronIDIncluded: Codable {
  let attributes: IncludedAttributes
  let id: String
  let type: String
  
  struct IncludedAttributes: Codable {
    let addressee: String?
    let city: String?
    let line_1: String?
    let line_2: String?
    let postal_code: String?
  }
}
