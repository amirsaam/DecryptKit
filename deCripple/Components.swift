//
//  Components.swift
//  deCripple
//
//  Created by Amir Mohammadi on 9/10/1401 AP.
//

import SwiftUI
import Neumorphic

struct SidebarBackground: View {
  var body: some View {
    Rectangle()
      .fill(mainColor)
      .transition(.move(edge: .trailing))
      .zIndex(1)
      .ignoresSafeArea(.all)
      .softOuterShadow()
  }
}

struct ErrorMessage: View {
  @State var errorLog: String
  var body: some View {
    Text(errorLog)
      .font(.subheadline)
      .foregroundColor(.red)
  }
}

struct Creators: View {
  var body: some View {
    ZStack {
      mainColor
      VStack(alignment: .leading) {
        Text("DecryptKit Creators:")
          .font(.subheadline)
        Group {
          Text("amirsaam#3579")
            .padding(.top, 1)
          Text("Amachi -アマチ#1131")
        }
        .font(.subheadline.monospaced())
      }
    }
  }
}
