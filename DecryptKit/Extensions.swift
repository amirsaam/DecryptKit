//
//  Extensions.swift
//  deCripple
//
//  Created by Amir Mohammadi on 8/29/1401 AP.
//

import SwiftUI
import SafariServices

/// Making custom colors availble as .color
extension Color {
  static let invertNeuPC = Color("invertNeuPC")
  static let invertNeuSC = Color("invertNeuSC")
  static let redNeuDS = Color("redNeuDS")
  static let redNeuLS = Color("redNeuLS")
}

/// Parse any URL for its Query Items
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

/// Shaking animation
struct Shake: GeometryEffect {
  var amount: CGFloat = 10
  var shakesPerUnit = 3
  var animatableData: CGFloat
  
  func effectValue(size: CGSize) -> ProjectionTransform {
    ProjectionTransform(CGAffineTransform(translationX: amount * sin(animatableData * .pi * CGFloat(shakesPerUnit)), y: 0))
  }
}

/// Email address validation function
func isValidEmailAddress(emailAddressString: String) -> Bool {
  
  var returnValue = true
  let emailRegEx = "[A-Z0-9a-z.-_]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,3}"
  
  do {
    let regex = try NSRegularExpression(pattern: emailRegEx)
    let nsString = emailAddressString as NSString
    let results = regex.matches(in: emailAddressString, range: NSRange(location: 0, length: nsString.length))
    
    if results.count == 0
    {
      returnValue = false
    }
    
  } catch let error as NSError {
    print("invalid regex: \(error.localizedDescription)")
    returnValue = false
  }
  
  return  returnValue
}

/// Check if an String contains only Number
extension String {
  var isNumber: Bool {
    return self.range(
      of: "^[0-9]*$",
      options: .regularExpression) != nil
  }
}

/// Defining decryption request types
enum deReqType {
  case new, queue, done
}
