//
//  UserIdentity.swift
//  DecryptKit
//
//  Created by Amir Mohammadi on 11/11/1401 AP.
//

import Foundation

struct PatreonUserIdentity: Codable {
  let data: Data
  let included: [Included]?
  let links: Links
  
  struct Data: Codable {
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
        let data: IdTypePlain
        let links: CampaignLinks
        
        struct CampaignLinks: Codable {
          let related: String
        }
      }
    }
  }
  
  struct Included: Codable {
    let attributes: IncludedAttributes
    let id: String
    let type: String
    
    struct IncludedAttributes: Codable {
      let is_monthly: Bool
      let summary: String
    }
  }
  
  struct Links: Codable {
    let `self`: String
  }
}
