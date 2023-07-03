//
//  RepoAppDetails.swift
//  deCripple
//
//  Created by Amir Mohammadi on 9/11/1401 AP.
//

import SwiftUI
import Neumorphic
import CachedAsyncImage
import DataCache

// MARK: - App Details Definer
struct RepoAppDetails: View {

  @State var isVIP: Bool
  @State var appBundleID: String
  @State var appName: String
  @State var appVersion: String
  
  var body: some View {
    if outAppStoreBundleID.contains(appBundleID) {
      OutAppStore(isVIP: $isVIP,
                  appBundleID: appBundleID,
                  appName: appName,
                  appVersion: appVersion)
    } else {
      InAppStore(appBundleID: appBundleID,
                 appVersion: appVersion)
    }
  }
}

// MARK: - AppStore Apps View
struct InAppStore: View {

  @State var appBundleID: String
  @State var appVersion: String

  @State private var lookedup: ITunesResponse?

  var body: some View {
    VStack(alignment: .leading, spacing: 15) {
      HStack(spacing: 10) {
        if let url = URL(string: lookedup?.results[0].artworkUrl512 ?? "") {
          CachedAsyncImage(url: url) { image in
            image
              .resizable()
              .aspectRatio(contentMode: .fit)
          } placeholder: {
            Rectangle()
              .fill(mainColor)
              .overlay {
                ProgressView()
              }
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
        Text(lookedup?.results[0].formattedPrice ?? "")
        Divider()
          .frame(height: 10)
        let dataSize = ByteCountFormatter
          .string(
            fromByteCount: Int64(lookedup?.results[0].fileSizeBytes ?? "") ?? 0,
            countStyle: .file
          )
        Text(dataSize)
        Divider()
          .frame(height: 10)
        Text(lookedup?.results[0].primaryGenreName ?? "")
        Divider()
          .frame(height: 10)
        Text(appVersion == lookedup?.results[0].version
             ? "Up to Date"
             : "\(appVersion) < \(lookedup?.results[0].version ?? "")"
        )
      }
      .font(.caption)
    }
    .task {
      if !cache.hasData(forKey: appBundleID) {
        resolveLookupData(appBundleID)
      }
      lookedup = try? cache.readCodable(forKey: appBundleID)
    }
  }
}

// MARK: - Custom Apps View
struct OutAppStore: View {

  @Binding var isVIP: Bool

  @State var appBundleID: String
  @State var appName: String
  @State var appVersion: String

  var body: some View {
    let app = NotAPApp(rawValue: appBundleID)
    VStack(alignment: .leading, spacing: 15) {
      HStack(spacing: 10) {
        if let url = URL(string: app?.appIcon ?? "ProgressBarForever") {
          CachedAsyncImage(url: url) { image in
            image
              .resizable()
              .aspectRatio(contentMode: .fit)
          } placeholder: {
            Rectangle()
              .fill(mainColor)
              .overlay {
                ProgressView()
              }
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
        Text(isVIP ? "Unbuyable" : "From GitHub")
        Divider()
          .frame(height: 10)
        let dataSize = ByteCountFormatter
          .string(
            fromByteCount: Int64(app?.appSize ?? "") ?? 0,
            countStyle: .file
          )
        Text(dataSize)
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
