//
//  Extensions.swift
//  deCripple
//
//  Created by Amir Mohammadi on 8/29/1401 AP.
//

import SwiftUI
import SafariServices

// MARK: - Custom Colours
extension Color {
  static let invertNeuPC = Color("invertNeuPC")
  static let invertNeuSC = Color("invertNeuSC")
  static let redNeuDS = Color("redNeuDS")
  static let redNeuLS = Color("redNeuLS")
}

// MARK: - Parse URL for Query Items
extension URL {
  func params() -> [String : Any] {
    var dict = [String : Any]()
    if let components = URLComponents(url: self, resolvingAgainstBaseURL: false) {
      if let queryItems = components.queryItems {
        for item in queryItems {
          dict[item.name] = item.value!
        }
      }
      return dict
    } else {
      return [:]
    }
  }
}

// MARK: - Shaking animation
struct Shake: GeometryEffect {
  var amount: CGFloat = 10
  var shakesPerUnit = 3
  var animatableData: CGFloat
  func effectValue(size: CGSize) -> ProjectionTransform {
    ProjectionTransform(
      CGAffineTransform(
        translationX: amount * sin(animatableData * .pi * CGFloat(shakesPerUnit)), y: 0
      )
    )
  }
}

// MARK: - Validatie Email Address
func isValidEmailAddress(emailAddressString: String) -> Bool {
  var returnValue = true
  let emailRegEx = "[A-Z0-9a-z.-_]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,3}"
  do {
    let regex = try NSRegularExpression(pattern: emailRegEx)
    let nsString = emailAddressString as NSString
    let results = regex.matches(in: emailAddressString, range: NSRange(location: 0, length: nsString.length))
    if results.count == 0 {
      returnValue = false
    }
  } catch let error as NSError {
    debugPrint("invalid regex: \(error.localizedDescription)")
    returnValue = false
  }
  return returnValue
}

// MARK: - Check if String is Number
extension String {
  var isNumber: Bool {
    return self.range(of: "^[0-9]*$", options: .regularExpression) != nil
  }
}

// MARK: - Conforming "Any" to Codable
struct AnyCodable: Codable {
  let value: Any?
  
  init<T>(_ value: T?) {
    self.value = value
  }
  
  init(from decoder: Decoder) throws {
    let container = try decoder.singleValueContainer()
    if container.decodeNil() {
      self.value = nil
    } else if let value = try? container.decode(Bool.self) {
      self.value = value
    } else if let value = try? container.decode(Int.self) {
      self.value = value
    } else if let value = try? container.decode(Double.self) {
      self.value = value
    } else if let value = try? container.decode(String.self) {
      self.value = value
    } else if let value = try? container.decode([String: AnyCodable].self) {
      self.value = value
    } else if let value = try? container.decode([AnyCodable].self) {
      self.value = value
    } else {
      throw DecodingError.dataCorruptedError(in: container,
                                             debugDescription: "AnyCodable value cannot be decoded")
    }
  }
  
  func encode(to encoder: Encoder) throws {
    var container = encoder.singleValueContainer()
    switch self.value {
    case nil:
      try container.encodeNil()
    case let value as Bool:
      try container.encode(value)
    case let value as Int:
      try container.encode(value)
    case let value as Double:
      try container.encode(value)
    case let value as String:
      try container.encode(value)
    case let value as [String: AnyCodable]:
      try container.encode(value)
    case let value as [AnyCodable]:
      try container.encode(value)
    default:
      throw EncodingError.invalidValue(self.value as Any, EncodingError.Context(
        codingPath: container.codingPath,
        debugDescription: "AnyCodable value cannot be encoded")
      )
    }
  }
}
