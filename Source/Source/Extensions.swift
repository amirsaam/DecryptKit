//
//  Extensions.swift
//  Source
//
//  Created by Amir Mohammadi on 8/29/1401 AP.
//

import SwiftUI
import SafariServices

struct SFSafariViewWrapper: UIViewControllerRepresentable {
  let url: URL
  func makeUIViewController(context: UIViewControllerRepresentableContext<Self>) -> SFSafariViewController {
    return SFSafariViewController(url: url)
  }
  func updateUIViewController(_ uiViewController: SFSafariViewController, context: UIViewControllerRepresentableContext<SFSafariViewWrapper>) {
    return
  }
}

extension Color {
  static let invertNeuPC = Color("invertNeuPC")
  static let invertNeuSC = Color("invertNeuSC")
  static let redNeuDS = Color("redButtonDarkShadow")
  static let redNeuLS = Color("redButtonLightShadow")
}

struct Shake: GeometryEffect {
  var amount: CGFloat = 10
  var shakesPerUnit = 3
  var animatableData: CGFloat
  
  func effectValue(size: CGSize) -> ProjectionTransform {
    ProjectionTransform(CGAffineTransform(translationX: amount * sin(animatableData * .pi * CGFloat(shakesPerUnit)), y: 0))
  }
}

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
