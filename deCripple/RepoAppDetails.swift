//
//  RepoAppDetails.swift
//  deCripple
//
//  Created by Amir Mohammadi on 9/11/1401 AP.
//

import SwiftUI
import Neumorphic

var outAppStoreBundleID: Array = ["ir.amrsm.deCripple", "com.rileytestut.Delta", "io.rosiecord"]

enum NotAPApp: String, CaseIterable {
  case deCripple = "ir.amrsm.deCripple"
  case delta = "com.rileytestut.Delta"
  case rosiecord = "io.rosiecord"
  
  var appIcon: String {
    switch self {
    case .deCripple: return ""
    case .delta: return "https://user-images.githubusercontent.com/705880/63391976-4d311700-c37a-11e9-91a8-4fb0c454413d.png"
    case .rosiecord: return ""
    }
  }
  var appDeveloper: String {
    switch self {
    case .deCripple: return ""
    case .delta: return "Riley Testut"
    case .rosiecord: return ""
    }
  }
  var appSize: String {
    switch self {
    case .deCripple: return ""
    case .delta: return "19713229"
    case .rosiecord: return ""
    }
  }
  var appGenre: String {
    switch self {
    case .deCripple: return ""
    case .delta: return "Utilities"
    case .rosiecord: return ""
    }
  }
}

struct RepoAppDetails: View {
  @Binding var sourceData: [deCrippleSource]?
  
  @State var appBundleID: String
  @State var appName: String
  @State var appVersion: String
  
  var body: some View {
    if outAppStoreBundleID.contains(appBundleID) {
      OutAppStore(appBundleID: appBundleID, appName: appName, appVersion: appVersion)
    } else {
      InAppStore(appBundleID: appBundleID, appVersion: appVersion)
    }
  }
}

struct InAppStore: View {

  @State var appBundleID: String
  @State var appVersion: String

  @State var lookedup: ITunesResponse?

  var body: some View {
    VStack(alignment: .leading, spacing: 15) {
      HStack(spacing: 10) {
        if let url = URL(string: lookedup?.results[0].artworkUrl60 ?? "") {
          AsyncImage(url: url) { image in
            image
              .resizable()
              .aspectRatio(contentMode: .fit)
          } placeholder: {
            ProgressView()
          }
          .frame(width: 50, height: 50)
          .cornerRadius(12)
          .softOuterShadow()
        }
        VStack(alignment: .leading, spacing: 5) {
          Text(lookedup?.results[0].trackName ?? "")
            .font(.headline)
          Text("by \(lookedup?.results[0].artistName ?? "")")
          .font(.caption)
        }
      }
      HStack(spacing: 5) {
        Text("\(ByteCountFormatter.string(fromByteCount: Int64(lookedup?.results[0].fileSizeBytes ?? "") ?? 0, countStyle: .file)) or less")
        Divider()
          .frame(height: 10)
        Text(lookedup?.results[0].primaryGenreName ?? "")
        Divider()
          .frame(height: 10)
        Text(appVersion == lookedup?.results[0].version
             ? "Up to Date"
             : "\(appVersion) > \(lookedup?.results[0].version ?? "")"
        )
      }
      .font(.caption)
    }
    .task {
      lookedup = await getITunesData(appBundleID)
    }
  }
}

struct OutAppStore: View {
  
  @State var appBundleID: String
  @State var appName: String
  @State var appVersion: String
  
  var body: some View {
    var app = NotAPApp(rawValue: appBundleID)
    VStack(alignment: .leading, spacing: 15) {
      HStack(spacing: 10) {
        if let url = URL(string: app?.appIcon ?? "") {
          AsyncImage(url: url) { image in
            image
              .resizable()
              .aspectRatio(contentMode: .fit)
          } placeholder: {
            ProgressView()
          }
          .frame(width: 50, height: 50)
          .cornerRadius(12)
          .softOuterShadow()
        }
        VStack(alignment: .leading, spacing: 5) {
          Text(appName)
            .font(.headline)
          Text("by \(app?.appDeveloper ?? "")")
            .font(.caption)
        }
      }
      HStack(spacing: 5) {
        Text("\(ByteCountFormatter.string(fromByteCount: Int64(app?.appSize ?? "") ?? 0, countStyle: .file)) or less")
        Divider()
          .frame(height: 10)
        Text(app?.appGenre ?? "")
        Divider()
          .frame(height: 10)
        Text(appVersion)
      }
      .font(.caption)
    }
  }
}
