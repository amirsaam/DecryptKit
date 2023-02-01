//
//  UserIdentity.swift
//  DecryptKit
//
//  Created by Amir Mohammadi on 11/11/1401 AP.
//

import Foundation

struct PatreonUserIdentity: Codable {
  let data: IdentityData
  let included: [IdentityIncluded]?
  let links: SelfLink
}

struct IdentityData: Codable {
  let attributes: Attributes
  let id: String
  let relationships: Relationships?
  let type: String
  
  struct Attributes: Codable {
    let email: String?
    let full_name: String
  }
  
  struct Relationships: Codable {
    let campaign: Campaign
    
    struct Campaign: Codable {
      let data: IdType
      let links: RelatedLink
    }
  }
}
  
struct IdentityIncluded: Codable {
  let attributes: IncludedAttributes
  let id: String
  let type: String
  
  struct IncludedAttributes: Codable {
    let is_monthly: Bool
    let summary: String
  }
}
