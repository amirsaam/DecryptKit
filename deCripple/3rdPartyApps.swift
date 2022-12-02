//
//  3rdPartyApps.swift
//  deCripple
//
//  Created by Amir Mohammadi on 9/11/1401 AP.
//

import Foundation

enum NotAPApp: String, CaseIterable {
  case deCripple = "ir.amrsm.deCripple"
  case delta = "com.rileytestut.Delta"
  case rosiecord = "io.rosiecord"
  
  var appIcon: String {
    switch self {
    case .deCripple: return ""
    case .delta: return "https://user-images.githubusercontent.com/705880/63391976-4d311700-c37a-11e9-91a8-4fb0c454413d.png"
    case .rosiecord: return "https://raw.githubusercontent.com/acquitelol/rosiecord/master/Icons/EnmityIcon-Icon-60_Normal%402x.png"
    }
  }
  var appDeveloper: String {
    switch self {
    case .deCripple: return ""
    case .delta: return "Riley Testut"
    case .rosiecord: return "acquite#0001"
    }
  }
  var appSize: String {
    switch self {
    case .deCripple: return ""
    case .delta: return "19713229"
    case .rosiecord: return "81474355"
    }
  }
  var appGenre: String {
    switch self {
    case .deCripple: return ""
    case .delta: return "Utilities"
    case .rosiecord: return "Social Networking"
    }
  }
}
