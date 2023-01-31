//
//  PatreonMedia.swift
//  DecryptKit
//
//  Created by Amir Mohammadi on 11/11/1401 AP.
//

import Foundation

struct PatreonMedia: Codable {
  let attributes: MediaAttributes

  struct MediaAttributes: Codable {
    let created_at: String
    let download_url: String
    let file_name: String
    let image_urls: [String: String]
    let metadata: [String: String]?
    let mimetype: String
    let owner_id: String
    let owner_relationship: String
    let owner_type: String
    let size_bytes: String
    let state: String
    let upload_expires_at: String
    let upload_parameters: String
    let upload_url: String
  }
}
