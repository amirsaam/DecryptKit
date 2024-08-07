//
//  CustomLookups.swift
//  deCripple
//
//  Created by Amir Mohammadi on 9/11/1401 AP.
//

import Foundation

let outAppStoreBundleID: Array = [
  "tech.deCripple",
  "com.rileytestut.Deltroid",
  "com.hammerandchisel.discord",
  "net.kdt.pojavlauncher",
  "xyz.skitty.Aidoku",
  "io.dreamteck.lifeslide",
  "com.rovio.AngryBirdsSpace",
  "com.valentinradu.silvertune",
  "com.rockstargames.gtalcs",
  "com.squareenixmontreal.deusexgo"
]

enum NotAPApp: String, CaseIterable {
  case deCripple = "tech.deCripple"
  case deltroid = "com.rileytestut.Deltroid"
  case rosiecord = "com.hammerandchisel.discord"
  case pojav = "net.kdt.pojavlauncher"
  case aidoku = "xyz.skitty.Aidoku"
  case lifeslide = "io.dreamteck.lifeslide"
  case abSpace = "com.rovio.AngryBirdsSpace"
  case cadenza = "com.valentinradu.silvertune"
  case gtalcs = "com.rockstargames.gtalcs"
  case deusexgo = "com.squareenixmontreal.deusexgo"
  
  var appIcon: String {
    switch self {
    case .deCripple: return "https://raw.githubusercontent.com/amirsaam/DecryptKit/main/AppLogos/DecryptKit-BBG.jpg"
    case .deltroid: return "https://raw.githubusercontent.com/lonkelle/Deltroid/356f9c50abcd7ef5f0f21581b36d27a8905390d4/Resources/Assets.xcassets/AppIcon.appiconset/icon-1024.png"
    case .rosiecord: return "https://raw.githubusercontent.com/acquitelol/rosiecord/master/Icons/EnmityIcon-Icon-60_Normal%402x.png"
    case .pojav: return "https://raw.githubusercontent.com/PojavLauncherTeam/PojavLauncher_iOS/main/Natives/Assets.xcassets/AppIcon-Dark.appiconset/AppIcon-Dark_1024x1024.png"
    case .aidoku: return "https://raw.githubusercontent.com/Aidoku/Aidoku/main/Shared/Assets.xcassets/AppIcon.appiconset/Icon.png"
    case .lifeslide: return "https://repo.decryptkit.xyz/icons/Lifeslide.png"
    case .abSpace: return "https://repo.decryptkit.xyz/icons/AngryBirdsSpace.png"
    case .cadenza: return "https://repo.decryptkit.xyz/icons/Cadenza.png"
    case .gtalcs: return "https://repo.decryptkit.xyz/icons/GTA-LC-S.png"
    case .deusexgo: return "https://repo.decryptkit.xyz/icons/DeusExGO.png"
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
    case .cadenza: return "Codewise Systems SRL-D"
    case .gtalcs: return "Rockstar Games"
    case .deusexgo: return "CDE Entertainment Ltd."
    }
  }
  var appSize: String {
    switch self {
    case .deCripple: return "4300000"
    case .deltroid: return "19713229"
    case .rosiecord: return "81474355"
    case .pojav: return "110100480"
    case .aidoku: return "4194304"
    case .lifeslide: return "739980000"
    case .abSpace: return "139990000"
    case .cadenza: return "5930000"
    case .gtalcs: return "1860000000"
    case .deusexgo: return "278780000"
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
    case .gtalcs: return "Games"
    case .deusexgo: return "Games"
    }
  }
}
