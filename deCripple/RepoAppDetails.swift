//
//  RepoAppDetails.swift
//  deCripple
//
//  Created by Amir Mohammadi on 9/11/1401 AP.
//

import SwiftUI
import Neumorphic

struct RepoAppDetails: View {
  
  @State var appBundleID: String
  @State var appName: String
  @State var appVersion: String

  @State var lookedup: ITunesResponse?
  
  var body: some View {
    VStack(alignment: .leading, spacing: 15) {
      HStack(spacing: 10) {
        if let url = URL(string: lookedup?.results[0].artworkUrl60 ?? "ProgressViewForever") {
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
          Text(lookedup?.results[0].trackName ?? appName)
            .font(.headline)
          Text("by \(lookedup?.results[0].artistName ?? "NOT ON APPSTORE")")
            .font(.caption)
        }
      }
      HStack(spacing: 5) {
        Text("\(ByteCountFormatter.string(fromByteCount: Int64(lookedup?.results[0].fileSizeBytes ?? "") ?? 0, countStyle: .file)) or less")
        Divider()
          .frame(height: 10)
        Text(lookedup?.results[0].primaryGenreName ?? "NONE")
        Divider()
          .frame(height: 10)
        Text(appVersion == lookedup?.results[0].version
             ? "Up to Date"
             : "\(appVersion) < \(lookedup?.results[0].version ?? "0.0.0")")
      }
      .font(.caption)
    }
      .task {
        lookedup = await getITunesData(appBundleID)
      }
  }
}
