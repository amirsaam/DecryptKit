//
//  LookupAppDetails.swift
//  deCripple
//
//  Created by Amir Mohammadi on 9/6/1401 AP.
//

import SwiftUI
import Neumorphic
import CachedAsyncImage

struct LookupAppDetails: View {

  @Binding var lookedup: ITunesResponse?

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
          .font(.caption)
        Divider()
          .frame(height: 10)
        Text("vr\(lookedup?.results[0].version ?? "")")
        Divider()
          .frame(height: 10)
        Text("\(ByteCountFormatter.string(fromByteCount: Int64(lookedup?.results[0].fileSizeBytes ?? "") ?? 0, countStyle: .file)) or less")
        Divider()
          .frame(height: 10)
        Text(lookedup?.results[0].primaryGenreName ?? "")
      }
      .font(.caption)
    }
    .padding(.top)
  }
}
