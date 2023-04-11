//
//  CreatorsView.swift
//  deCripple
//
//  Created by Amir Mohammadi on 1/22/1402 AP.
//

import SwiftUI
import Neumorphic

// MARK: - DecryptKit People
struct CreatorsView: View {
  var body: some View {
    ZStack {
      mainColor
      VStack(alignment: .leading, spacing: 20) {
        VStack(alignment: .leading) {
          Text("Designed and Developed")
          HStack {
            Text("with")
            Image(systemName: "heart.fill")
              .foregroundColor(.red)
            Text("by Paramea Team")
          }
        }
        .font(.subheadline.monospaced())
        VStack(spacing: 10) {
          HStack {
            Text("Check out Paramea's Github Page")
            Spacer()
            Button {
              if let url = URL(string: "https://github.com/Paramea") {
                UIApplication.shared.open(url)
              }
            } label: {
              Image(systemName: "arrow.right")
                .font(.caption2)
            }
            .softButtonStyle(
              Circle(),
              padding: 8,
              pressedEffect: .flat
            )
          }
          .frame(width: 300)
          HStack {
            Text("Join DecryptKit's Discord Server!")
            Spacer()
            Button {
              if let url = URL(string: "https://discord.gg/22znF2eHGw") {
                UIApplication.shared.open(url)
              }
            } label: {
              Image(systemName: "arrow.right")
                .font(.caption2)
            }
            .softButtonStyle(
              Circle(),
              padding: 8,
              pressedEffect: .flat
            )
          }
          .frame(width: 300)
        }
        .font(.subheadline)
        VStack(alignment: .leading, spacing: 10) {
          Text("Special Thanks to:")
            .font(.subheadline)
          VStack(spacing: 2.5) {
            Text("• Depal#7088")
            Text("• Zhich#6244")
          }
          .font(.subheadline.monospaced())
        }
      }
    }
  }
}
