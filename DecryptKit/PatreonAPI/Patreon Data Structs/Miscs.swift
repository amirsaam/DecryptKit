//
//  Miscs.swift
//  DecryptKit
//
//  Created by Amir Mohammadi on 11/11/1401 AP.
//

import Foundation

struct IdTypePlain: Codable {
  let id: String
  let type: String
}

struct IdTypeArray: Codable {
  let data: [InnerArray]
  
  struct InnerArray: Codable {
    let id: String
    let type: String
  }
}

struct SelfLink: Codable {
    let `self`: String
}
