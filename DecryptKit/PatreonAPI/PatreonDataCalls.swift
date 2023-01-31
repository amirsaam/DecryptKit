//
//  PatreonAPICalls.swift
//  DecryptKit
//
//  Created by Amir Mohammadi on 11/10/1401 AP.
//

import Foundation
import Alamofire
import Semaphore

// MARK: - Patreon API Calls
extension PatreonAPI {

  // Returns User's Patreon Account Information
  func getUserIdentity(_ userPAT: String) async -> PatreonUserIdentity? {
    let returnValue: PatreonUserIdentity?
    let path = "identity"
    let queries = [
      URLQueryItem(name: "fields[user]",
                   value: "about,created,email,first_name,full_name,image_url,last_name,social_connections,thumb_url,url,vanity")
    ]
    let fetchedData = await fetchPatreonData(userPAT, path, queries,
                                             PatreonUserIdentity.self)
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
                   value: "created_at,creation_name,discord_server_id,google_analytics_id,has_rss,has_sent_rss_notify,image_small_url,image_url,is_charged_immediately,is_monthly,is_nsfw,main_video_embed,main_video_url,one_liner,patron_count,pay_per_name,pledge_url,published_at,rss_artwork_url,rss_feed_title,show_earnings,summary,thanks_embed,thanks_msg,thanks_video_url,url,vanity")
    ]
    let fetchedData = await fetchPatreonData(userPAT, path, queries,
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
      URLQueryItem(name: "include", value: "benefits,creator,goals,tiers"),
      URLQueryItem(name: "fields[campaign]",
                   value: "created_at,creation_name,discord_server_id,google_analytics_id,has_rss,has_sent_rss_notify,image_small_url,image_url,is_charged_immediately,is_monthly,is_nsfw,main_video_embed,main_video_url,one_liner,patron_count,pay_per_name,pledge_url,published_at,rss_artwork_url,rss_feed_title,show_earnings,summary,thanks_embed,thanks_msg,thanks_video_url,url,vanity"),
      URLQueryItem(name: "fields[tier]",
                   value: "amount_cents,created_at,description,discord_role_ids,edited_at,image_url,patron_count,post_count,published,published_at,remaining,requires_shipping,title,unpublished_at,url,user_limit"),
      URLQueryItem(name: "fields[benefit]",
                   value: "app_external_id,app_meta,benefit_type,created_at,deliverables_due_today_count,delivered_deliverables_count,description,is_deleted,is_ended,is_published,next_deliverable_due_date,not_delivered_deliverables_count,rule_type,tiers_count,title")
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
