//
//  PatreonAPI.swift
//  DecryptKit
//
//  Created by Amir Mohammadi on 10/11/1401 AP.
//

import Foundation
import SwiftUI
import Alamofire
import Semaphore

// MARK: - Patreon Client Details
struct PatreonClient {
  let clientID = "MKzRZxagIOea-ceFt_54sjf9yyA2TzTHln9LiUoybU8ZRg7ljS4KE9HrBPa9i6aA"
  let clientSecret = "4kTPw037oTE6D9zGHDwBgxqljtd70UkLBXAA25lIk83ZRbrlQjNr3sN8-TFa8dI6"
  let creatorAccessToken = "3YVSAbYWvmtWCEmVItQaXjZGyHqYgGy8_w4mVV_47h4"
  let creatorRefreshToken = "NjmDj3mZ1b5ae7zcNKZD6cmZRtfsEdddCnRvaywliL4"
  let redirectURI = "https://decryptkit.xyz/patreon/6NvbE37T33cKTmpu1DkAtvuEK4XdWzF"
  let campaignID = "9760149"
}

// MARK: - Patron's OAuth Detail
struct PatronOAuth: Codable {
  let access_token: String
  let refresh_token: String
  let expires_in: Int
  let scope: String
  let token_type: String
}

// MARK: - Patreon Class
class Patreon {
  private let client = PatreonClient()
  private let almonfire = AF
  
// MARK: - 1st OAuth Call
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

// MARK: - Get User Tokens
  func getOAuthTokens(_ code: String) async -> PatronOAuth? {
    let params: [String: String] = ["code": code,
                                    "grant_type": "authorization_code",
                                    "client_id": client.clientID,
                                    "client_secret": client.clientSecret,
                                    "redirect_uri": client.redirectURI]
    return await fetchOAuthResponse(params)
  }

// MARK: - Refresh User Tokens
  func refreshOAuthTokens(_ refreshToken: String) async -> PatronOAuth? {
    let params: [String: String] = ["grant_type": "refresh_token",
                                    "refresh_token": refreshToken,
                                    "client_id": client.clientID,
                                    "client_secret": client.clientSecret]
    return await fetchOAuthResponse(params)
  }

// MARK: - Fetch Tokens Fucntion
  private func fetchOAuthResponse(_ params: Dictionary<String, String>) async -> PatronOAuth? {
    var requestResponse: PatronOAuth?
    let semaphore = AsyncSemaphore(value: 0)
    guard let url = URL(string: "https://www.patreon.com/api/oauth2/token") else { return nil }
    let headers: HTTPHeaders = ["Content-Type": "application/x-www-form-urlencoded"]
    almonfire.request(url,
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

/*
class API {
  private var access_token: String
  public var api_endpoint: String
  public var request_cache: [String: Any]
  public var api_request_method: String
  public var api_return_format: String
  
  public init(access_token: String) {
    self.access_token = access_token
    self.api_endpoint = "https://www.patreon.com/api/oauth2/v2/"
    self.request_cache = [:]
    self.api_request_method = "GET"
    self.api_return_format = "array"
  }
  
  public func fetch_user() -> [String: Any] {
    return get_data(suffix: "identity?include=memberships&fields\(urlencode("[user]"))=email,first_name,full_name,image_url,last_name,thumb_url,url,vanity,is_email_verified&fields\(urlencode("[member]"))=currently_entitled_amount_cents,lifetime_support_cents,last_charge_status,patron_status,last_charge_date,pledge_relationship_start")
  }
  
  public func fetch_campaigns() -> [String: Any] {
    return get_data(suffix: "campaigns")
  }
  
  public func fetch_campaign_details(campaign_id: Int) -> [String: Any] {
    return get_data(suffix: "campaigns/\(campaign_id)?include=benefits,creator,goals,tiers")
  }
  
  public func fetch_member_details(member_id: Int) -> [String: Any] {
    return get_data(suffix: "members/\(member_id)?include=address,campaign,user,currently_entitled_tiers")
  }
  
  public func fetch_page_of_members_from_campaign(campaign_id: Int, page_size: Int, cursor: String?) -> [String: Any] {
    var url = "campaigns/\(campaign_id)/members?page%5Bsize%5D=\(page_size)"
    if cursor != nil {
      let escaped_cursor = cursor!.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
      url += "&page%5Bcursor%5D=\(escaped_cursor!)"
    }
    return get_data(suffix: url)
  }
  
  private func get_data(suffix: String, args: [String: Any] = [:]) -> [String: Any] {
    let api_request = api_endpoint + suffix
    let api_request_hash = api_request.md5()
    if !args.keys.contains("skip_read_from_cache") {
      if let result = request_cache[api_request_hash] {
        return result as! [String: Any]
      }
    }
    var request = URLRequest(url: URL(string: api_request)!)
    request.httpMethod = api_request_method
    request.addValue("Bearer \(access_token)", forHTTPHeaderField: "Authorization")
    if api_request_method == "POST" {
      request.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
    }
    let task = URLSession.shared.dataTask(with: request) { data, response, error in
      guard let data = data, error == nil else {
        print(error?.localizedDescription ?? "No data")
        return
      }
      let httpStatus = response as? HTTPURLResponse
      if httpStatus?.statusCode >= 500 {
        self.add_to_request_cache(api_request_hash: api_request_hash, json_string: data)
      }
      if httpStatus?.statusCode >= 400 {
        self.add_to_request_cache(api_request_hash: api_request_hash, json_string: data)
      }
      if self.api_return_format == "array" {
        let returnData = try! JSONSerialization.jsonObject(with: data, options: []) as! [String: Any]
        self.add_to_request_cache(api_request_hash: api_request_hash, json_string: returnData)
      }
      if self.api_return_format == "object" {
        let returnData = try! JSONSerialization.jsonObject(with: data, options: [])
        self.add_to_request_cache(api_request_hash: api_request_hash, json_string: returnData)
      }
      if self.api_return_format == "json" {
        let returnData = try! JSONSerialization.data(withJSONObject: data, options: [])
        self.add_to_request_cache(api_request_hash: api_request_hash, json_string: returnData)
      }
    }
    task.resume()
    return self.request_cache[api_request_hash] as! [String: Any]
  }
  
  private func add_to_request_cache(api_request_hash: String, json_string: Any) {
    request_cache[api_request_hash] = json_string
  }
}
*/
