//
//  CustomLookups.swift
//  deCripple
//
//  Created by Amir Mohammadi on 9/11/1401 AP.
//

import Foundation

let outAppStoreBundleID: Array = [
  "ir.amrsm.deCripple",
  "com.rileytestut.Deltroid",
  "com.hammerandchisel.discord",
  "net.kdt.pojavlauncher"
]

enum NotAPApp: String, CaseIterable {
  case deCripple = "ir.amrsm.deCripple"
  case deltroid = "com.rileytestut.Deltroid"
  case rosiecord = "com.hammerandchisel.discord"
  case pojav = "net.kdt.pojavlauncher"
  
  var appIcon: String {
    switch self {
    case .deCripple: return "https://raw.githubusercontent.com/amirsaam/DecryptKit/main/DecryptKit.jpg"
    case .deltroid: return "https://raw.githubusercontent.com/lonkelle/Deltroid/356f9c50abcd7ef5f0f21581b36d27a8905390d4/Resources/Assets.xcassets/AppIcon.appiconset/icon-1024.png"
    case .rosiecord: return "https://raw.githubusercontent.com/acquitelol/rosiecord/master/Icons/EnmityIcon-Icon-60_Normal%402x.png"
    case .pojav: return "https://raw.githubusercontent.com/PojavLauncherTeam/PojavLauncher_iOS/main/Natives/Assets.xcassets/AppIcon-Dark.appiconset/AppIcon-Dark_1024x1024.png"
    }
  }
  var appDeveloper: String {
    switch self {
    case .deCripple: return "Paramea Team"
    case .deltroid: return "Joelle Stickney"
    case .rosiecord: return "Acquite#0001"
    case .pojav: return "PojavLauncherTeam"
    }
  }
  var appSize: String {
    switch self {
    case .deCripple: return "2097152"
    case .deltroid: return "19713229"
    case .rosiecord: return "81474355"
    case .pojav: return "110100480"
    }
  }
  var appGenre: String {
    switch self {
    case .deCripple: return "Utilities"
    case .deltroid: return "Utilities"
    case .rosiecord: return "Social Networking"
    case .pojav: return "Games"
    }
  }
}
