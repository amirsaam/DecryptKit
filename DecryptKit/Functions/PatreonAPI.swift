//
//  PatreonAPI.swift
//  deCripple
//
//  Created by Amir Mohammadi on 10/11/1401 AP.
//

import Foundation
import SwiftUI
import Alamofire
import Semaphore

// MARK: - Patreon Client Details
private struct PatreonClient {
  let clientID = "MKzRZxagIOea-ceFt_54sjf9yyA2TzTHln9LiUoybU8ZRg7ljS4KE9HrBPa9i6aA"
  let clientSecret = "4kTPw037oTE6D9zGHDwBgxqljtd70UkLBXAA25lIk83ZRbrlQjNr3sN8-TFa8dI6"
  let creatorAccessToken = "mfN-03GqFy6AiE7Jzq-I7CEdWuXfHMg_2VlLO0kcMgE"
  let creatorRefreshToken = "rnz8ny-qw8kdVM3bFyL27fssb1jRqta11WARXfPUm_Q"
  let redirectURI = "https://decryptkit.xyz/patreon/6NvbE37T33cKTmpu1DkAtvuEK4XdWzF"
  let campaignID = "9760149"
}

// MARK: - Patreon Class
class Patreon {
  private let client = PatreonClient()
  public static let shared = Patreon()
}

// MARK: - Patreon OAuth Calls
extension Patreon {

  // 1st OAuth Call
  func doOAuth() {
    var urlComponents = URLComponents()
    urlComponents.scheme = "https"
    urlComponents.host = "www.patreon.com"
    urlComponents.path = "/oauth2/authorize"
    urlComponents.queryItems = [
      URLQueryItem(name: "response_type", value: "code"),
      URLQueryItem(name: "client_id", value: client.clientID),
      URLQueryItem(name: "redirect_uri", value: client.redirectURI)
    ]
    guard let url = urlComponents.url else { return }
    UIApplication.shared.open(url)
  }

  // Get User Tokens
  func getOAuthTokens(_ code: String) async -> PatronOAuth? {
    let params: [String: String] = ["code": code,
                                    "grant_type": "authorization_code",
                                    "client_id": client.clientID,
                                    "client_secret": client.clientSecret,
                                    "redirect_uri": client.redirectURI]
    return await fetchOAuthResponse(params)
  }

  // Refresh User Tokens
  func refreshOAuthTokens(_ refreshToken: String) async -> PatronOAuth? {
    let params: [String: String] = ["grant_type": "refresh_token",
                                    "refresh_token": refreshToken,
                                    "client_id": client.clientID,
                                    "client_secret": client.clientSecret]
    return await fetchOAuthResponse(params)
  }

  // Fetch Tokens Fucntion
  private func fetchOAuthResponse(
    _ params: Dictionary<String, String>
  ) async -> PatronOAuth? {

    let semaphore = AsyncSemaphore(value: 0)
    var requestResponse: PatronOAuth?
  
    guard let url = URL(string: "https://www.patreon.com/api/oauth2/token") else { return nil }
    let headers: HTTPHeaders = ["Content-Type": "application/x-www-form-urlencoded"]

    alamofire.request(url,
                      method: .post,
                      parameters: params,
                      headers: headers)
    .responseDecodable(of: PatronOAuth.self) {
      (response: DataResponse<PatronOAuth, AFError>) in
      switch response.result {
      case .success(let data):
        requestResponse = data
      case .failure(let error):
        debugPrint(error)
        requestResponse = nil
      }
      semaphore.signal()
    }

    await semaphore.wait()
    return requestResponse
  }

}

// MARK: - Patron's OAuth Struct
struct PatronOAuth: Codable {
  let access_token: String
  let refresh_token: String
  let expires_in: Int
  let scope: String
  let token_type: String
}

// MARK: - Patreon API Calls
extension Patreon {

  // Returns User's Patreon Account Information
  func getUserIdentity(_ userPAT: String) async -> PatronIdentity? {
    let returnValue: PatronIdentity?
    let path = "identity"
    let queries = [
      URLQueryItem(name: "fields[user]",
                   value: "about,created,email,first_name,full_name,image_url,last_name,social_connections,thumb_url,url,vanity")
    ]
    let fetchedData = await fetchPatreonData(userPAT, path, queries,
                                             PatronIdentity.self)
    if let identity = fetchedData {
      returnValue = identity
      debugPrint(identity)
    } else {
      returnValue = nil
      debugPrint("failed to fetch identity")
    }
    return returnValue
  }

  // Returns Campaigns owned by the User
  func getUserOwnedCampaigns(_ userPAT: String) async -> PatronOwnedCampaigns? {
    let returnValue: PatronOwnedCampaigns?
    let path = "campaigns"
    let queries = [
      URLQueryItem(name: "fields[campaign]",
                   value: "created_at,creation_name,discord_server_id,image_small_url,image_url,is_charged_immediately,is_monthly,is_nsfw,main_video_embed,main_video_url,one_liner,one_liner,patron_count,pay_per_name,pledge_url,published_at,summary,thanks_embed,thanks_msg,thanks_video_url,has_rss,has_sent_rss_notify,rss_feed_title,rss_artwork_url,patron_count,discord_server_id,google_analytics_id")
    ]
    let fetchedData = await fetchPatreonData(userPAT,path, queries,
                                             PatronOwnedCampaigns.self)
    if let ownedCampaigns = fetchedData {
      returnValue = ownedCampaigns
      debugPrint(ownedCampaigns)
    } else {
      returnValue = nil
      debugPrint("failed to fetch ownedCampaigns")
    }
    return returnValue
  }

  // Returns details about a Campaign identified by ID
  func getDataForCampaign() async -> PatreonCampaignInfo? {
    let returnValue: PatreonCampaignInfo?
    let path = "campaigns/" + client.campaignID
    let queries = [
      URLQueryItem(name: "fields[campaign]",
                   value: "created_at,creation_name,discord_server_id,image_small_url,image_url,is_charged_immediately,is_monthly,main_video_embed,main_video_url,one_liner,one_liner,patron_count,pay_per_name,pledge_url,published_at,summary,thanks_embed,thanks_msg,thanks_video_url")
    ]
    let fetchedData = await fetchPatreonData(client.creatorAccessToken,
                                             path, queries,
                                             PatreonCampaignInfo.self)
    if let campaignData = fetchedData {
      returnValue = campaignData
      debugPrint(campaignData)
    } else {
      returnValue = nil
      debugPrint("failed to fetch campaignData")
    }
    return returnValue
  }

  // Returns a list Patrons of a Campaign identified by ID
  func getMembersForCampaign() async -> PatreonCampaignMembers? {
    let returnValue: PatreonCampaignMembers?
    let path = "campaigns/" + client.campaignID + "/members"
    let query = [
      URLQueryItem(name: "include", value: "currently_entitled_tiers,address"),
      URLQueryItem(name: "fields[member]",
                   value: "full_name,is_follower,last_charge_date,last_charge_status,lifetime_support_cents,currently_entitled_amount_cents,patron_status"),
      URLQueryItem(name: "fields[tier]",
                   value: "amount_cents,created_at,description,discord_role_ids,edited_at,patron_count,published,published_at,requires_shipping,title,url"),
      URLQueryItem(name: "fields[address]",
                   value: "addressee,city,line_1,line_2,phone_number,postal_code,state")
    ]
    let fetchedData = await fetchPatreonData(client.creatorAccessToken,
                                             path, query,
                                             PatreonCampaignMembers.self)
    if let campaignMembers = fetchedData {
      returnValue = campaignMembers
      debugPrint(campaignMembers)
    } else {
      returnValue = nil
      debugPrint("failed to fetch campaignMembers")
    }
    return returnValue
  }

  // Returns Details about a Campaign Patron identifies by ID
  func getMemberForCampaignByID(_ memberID: String) async -> PatronFetchedByID? {
    let returnValue: PatronFetchedByID?
    let path = "campaigns/members/" + memberID
    let query = [
      URLQueryItem(name: "fields[address]", value: "line_1,line_2,addressee,postal_code,city"),
      URLQueryItem(name: "fields[member]", value: "full_name,is_follower,last_charge_date"),
      URLQueryItem(name: "include", value: "address,user")
    ]
    let fetchedData = await fetchPatreonData(client.creatorAccessToken,
                                             path, query,
                                             PatronFetchedByID.self)
    if let fetchedPatron = fetchedData {
      returnValue = fetchedPatron
      debugPrint(fetchedPatron)
    } else {
      returnValue = nil
      debugPrint("failed to fetch fetchedPatron")
    }
    return returnValue
  }

  // Fetch Patreon Data Fucntion
  private func fetchPatreonData<T: Codable>(
    _ accessToken: String,
    _ apiPath: String,
    _ apiQueries: [URLQueryItem],
    _ returnType: T.Type
  ) async -> T? {

    let semaphore = AsyncSemaphore(value: 0)
    var data: T?

    var urlComponents = URLComponents()
    urlComponents.scheme = "https"
    urlComponents.host = "www.patreon.com"
    urlComponents.path = "/api/oauth2/v2/" + apiPath
    urlComponents.queryItems = apiQueries

    guard let url = urlComponents.url else { return nil }
    debugPrint(url)

    let headers: HTTPHeaders = ["Authorization": "Bearer \(accessToken)"]
  
    alamofire.request(url,
                      method: .get,
                      headers: headers)
    .responseDecodable(of: T.self) {
      (response: DataResponse<T, AFError>) in
      switch response.result {
      case .success(let value):
        data = value
      case .failure(let error):
        data = nil
        debugPrint(error)
      }
      semaphore.signal()
    }

    await semaphore.wait()
    return data
  }

}

// MARK: - Patreon User Identity Struct
struct PatronIdentity: Codable {
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
        let data: CampaignData
        let links: CampaignLinks
        
        struct CampaignData: Codable {
          let id: String
          let type: String
        }
        
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

// MARK: - User's Campaign Struct
struct PatronOwnedCampaigns: Codable {
  let data: [Data]
  let meta: Meta
  
  struct Data: Codable {
    let attributes: Attributes
    let id: String
    let type: String
    
    struct Attributes: Codable {
      let created_at: String
      let creation_name: String
      let discord_server_id: String
      let google_analytics_id: String
      let has_rss: Bool
      let has_sent_rss_notify: Bool
      let image_small_url: String
      let image_url: String
      let is_charged_immediately: Bool
      let is_monthly: Bool
      let is_nsfw: Bool
      let main_video_embed: String?
      let main_video_url: String
      let one_liner: String?
      let patron_count: Int
      let pay_per_name: String
      let pledge_url: String
      let published_at: String
      let rss_artwork_url: String
      let rss_feed_title: String
      let summary: String
      let thanks_embed: String?
      let thanks_msg: String?
      let thanks_video_url: String?
    }
  }
  
  struct Meta: Codable {
    let pagination: Pagination
    
    struct Pagination: Codable {
      let total: Int
    }
  }
}

// MARK: - Campaign Details Struct
struct PatreonCampaignInfo: Codable {
  let data: Data
  
  struct Data: Codable {
    let attributes: Attributes
    let id: String
    let type: String
    
    struct Attributes: Codable {
      let created_at: String
      let creation_name: String
      let discord_server_id: String?
      let image_small_url: String
      let image_url: String
      let is_charged_immediately: Bool
      let is_monthly: Bool
      let main_video_embed: String?
      let main_video_url: String?
      let one_liner: String?
      let patron_count: Int
      let pay_per_name: String
      let pledge_url: String
      let published_at: String
      let summary: String
      let thanks_embed: String?
      let thanks_msg: String?
      let thanks_video_url: String?
    }
  }
}

// MARK: - Campaign's Patrons Struct
struct PatreonCampaignMembers: Codable {
  let data: [Data]
  let included: [Included]?
  let meta: Meta
  
  struct Data: Codable {
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
      let address: RelationshipData
      let currently_entitled_tiers: RelationshipArrayData
      
      struct RelationshipData: Codable {
        let data: Datum?
        
        struct Datum: Codable {
          let id: String
          let type: String
        }
      }
      struct RelationshipArrayData: Codable {
        let data: [ArrayDatum]
        
        struct ArrayDatum: Codable {
          let id: String?
          let type: String
        }
      }
    }
  }
  
  struct Included: Codable {
    let attributes: IncludedAttributes
    let id: String
    let type: String
    
    struct IncludedAttributes: Codable {
      let address: AddressAttributes?
      let tier: TierAttributes?
    }
    
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
  struct Meta: Codable {
    let pagination: Pagination
    
    struct Pagination: Codable {
      let cursors: Cursors
      let total: Int
      
      struct Cursors: Codable {
        let next: String?
      }
    }
  }
}

// MARK: - A Patron Details Struct
struct PatronFetchedByID: Codable {
  let data: Data
  let included: [Included]
  let links: Links
  
  struct Data: Codable {
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
        let data: Datum
        let links: Link
        
        struct Datum: Codable {
          let id: String
          let type: String
        }
        struct Link: Codable {
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
      let addressee: String?
      let city: String?
      let line_1: String?
      let line_2: String?
      let postal_code: String?
    }
  }
  
  struct Links: Codable {
    let self_link: String
  }
}
