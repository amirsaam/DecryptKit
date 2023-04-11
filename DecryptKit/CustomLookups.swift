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
  "net.kdt.pojavlauncher",
  "xyz.skitty.Aidoku",
  "io.dreamteck.lifeslide",
  "com.rovio.AngryBirdsSpace",
  "com.valentinradu.silvertune"
]

enum NotAPApp: String, CaseIterable {
  case deCripple = "ir.amrsm.deCripple"
  case deltroid = "com.rileytestut.Deltroid"
  case rosiecord = "com.hammerandchisel.discord"
  case pojav = "net.kdt.pojavlauncher"
  case aidoku = "xyz.skitty.Aidoku"
  case lifeslide = "io.dreamteck.lifeslide"
  case abSpace = "com.rovio.AngryBirdsSpace"
  case cadenza = "com.valentinradu.silvertune"
  
  var appIcon: String {
    switch self {
    case .deCripple: return "https://raw.githubusercontent.com/amirsaam/DecryptKit/main/DecryptKit.jpg"
    case .deltroid: return "https://raw.githubusercontent.com/lonkelle/Deltroid/356f9c50abcd7ef5f0f21581b36d27a8905390d4/Resources/Assets.xcassets/AppIcon.appiconset/icon-1024.png"
    case .rosiecord: return "https://raw.githubusercontent.com/acquitelol/rosiecord/master/Icons/EnmityIcon-Icon-60_Normal%402x.png"
    case .pojav: return "https://raw.githubusercontent.com/PojavLauncherTeam/PojavLauncher_iOS/main/Natives/Assets.xcassets/AppIcon-Dark.appiconset/AppIcon-Dark_1024x1024.png"
    case .aidoku: return "https://raw.githubusercontent.com/Aidoku/Aidoku/main/Shared/Assets.xcassets/AppIcon.appiconset/Icon.png"
    case .lifeslide: return "https://is5-ssl.mzstatic.com/image/thumb/Purple115/v4/19/40/55/19405582-e492-2155-a753-96d3b838a24d/AppIcon-1x_U007emarketing-0-7-0-85-220.png/512x512bb.jpg"
    case .abSpace: return "https://play-lh.googleusercontent.com/CXqjoN_u3sFyV_Z1M7E-4KmyI0tYe5FLHV5KosQC-0s5LsZuhm4omg-5nP6VBpIwilI=w480-h960"
    case .cadenza: return "https://is3-ssl.mzstatic.com/image/thumb/Purple123/v4/61/13/1a/61131a66-76c8-d89e-410e-f6d8024cedbf/source/420x420bb.png"
    }
  }
  var appDeveloper: String {
    switch self {
    case .deCripple: return "Paramea Team"
    case .deltroid: return "Joelle Stickney"
    case .rosiecord: return "Acquite#0001"
    case .pojav: return "PojavLauncherTeam"
    case .aidoku: return "Aidoku"
    case .lifeslide: return "Dreamteck"
    case .abSpace: return "Rovio Entertainment Oyj"
    case .cadenza: return "UNKNOWN"
    }
  }
  var appSize: String {
    switch self {
    case .deCripple: return "2097152"
    case .deltroid: return "19713229"
    case .rosiecord: return "81474355"
    case .pojav: return "110100480"
    case .aidoku: return "4194304"
    case .lifeslide: return "775946240"
    case .abSpace: return "146800640"
    case .cadenza: return "6291456"
    }
  }
  var appGenre: String {
    switch self {
    case .deCripple: return "Utilities"
    case .deltroid: return "Utilities"
    case .rosiecord: return "Social Networking"
    case .pojav: return "Games"
    case .aidoku: return "Books"
    case .lifeslide: return "Games"
    case .abSpace: return "Games"
    case .cadenza: return "Utilities"
    }
  }
}
