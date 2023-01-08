//
//  PatreonView.swift
//  DecryptKit
//
//  Created by Amir Mohammadi on 10/18/1401 AP.
//

import SwiftUI
import Neumorphic

struct PatreonView: View {

  @Binding var isDeeplink: Bool
  @Binding var showPatreon: Bool
  @Binding var callbackCode: String
  @Binding var callbackState: String

  @State private var patreon = Patreon()

  var body: some View {
    ZStack {
      if showPatreon {
        SidebarBackground()
          .overlay {
            VStack(alignment: .leading, spacing: 25.0) {
              Text("Click to OAuth")
                .onTapGesture {
                  patreon.oauth()
                }
              Button {
                withAnimation(.spring()) {
                  showPatreon = false
                }
              } label: {
                Image(systemName: "chevron.compact.right")
              }
              .softButtonStyle(
                Circle(),
                pressedEffect: .flat
              )
            }
          }
          .onAppear {
            if isDeeplink {
              handleCallback("onAppear")
            }
          }
          .onChange(of: isDeeplink) { boolean in
            if boolean {
              handleCallback("onChange")
            }
          }
      }
    }
  }
  func handleCallback(_ text: String) {
    print(text, callbackCode, callbackState)
    isDeeplink = false
  }
}
