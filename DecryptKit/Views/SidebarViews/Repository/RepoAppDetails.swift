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

var outAppStoreBundleID: Array = [
  "ir.amrsm.deCripple",
  "com.rileytestut.Delta",
  "com.hammerandchisel.discord"
]

struct RepoAppDetails: View {

  @Binding var doRefresh: Bool

  @State var appBundleID: String
  @State var appName: String
  @State var appVersion: String
  
  var body: some View {
    if outAppStoreBundleID.contains(appBundleID) {
      OutAppStore(appBundleID: appBundleID,
                  appName: appName,
                  appVersion: appVersion)
    } else {
      InAppStore(doRefresh: doRefresh,
                 appBundleID: appBundleID,
                 appVersion: appVersion)
    }
  }
}

struct InAppStore: View {

  @State var doRefresh: Bool
  @State var appBundleID: String
  @State var appVersion: String

  @State var lookedup: ITunesResponse?

  var body: some View {
    VStack(alignment: .leading, spacing: 15) {
      HStack(spacing: 10) {
        if let url = URL(string: lookedup?.results[0].artworkUrl60 ?? "") {
          CachedAsyncImage(url: url) { image in
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
        let dataSize = ByteCountFormatter
          .string(
            fromByteCount: Int64(lookedup?.results[0].fileSizeBytes ?? "") ?? 0,
            countStyle: .file
          )
        Text("\(dataSize) or less")
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
      if doRefresh || !DataCache.instance.hasData(forKey: appBundleID) {
        await resolveLookupData(appBundleID)
        doRefresh = false
      }
      do {
        lookedup = try DataCache.instance.readCodable(forKey: appBundleID)
      } catch {
        print("Read error \(error.localizedDescription)")
      }
    }
  }
}

struct OutAppStore: View {
  
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
        let dataSize = ByteCountFormatter
          .string(
            fromByteCount: Int64(app?.appSize ?? "") ?? 0,
            countStyle: .file
          )
        Text("\(dataSize) or less")
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
