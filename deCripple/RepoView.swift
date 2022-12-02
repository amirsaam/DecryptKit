//
//  RepoView.swift
//  deCripple
//
//  Created by Amir Mohammadi on 9/10/1401 AP.
//

import SwiftUI
import Neumorphic

struct RepoView: View {
  
  @Binding var showRepo: Bool
  @Binding var sourceData: [deCrippleSource]?
  
  @State var sourceLookedup: ITunesResponse?
  
  var body: some View {
    GeometryReader { geo in
      ZStack {
        if showRepo {
          SidebarBackground()
            .overlay {
              VStack(alignment: .leading) {
                HStack {
                  Button {
                    withAnimation(.spring()) {
                      showRepo = false
                    }
                  } label: {
                    Image(systemName: "chevron.compact.right")
                  }
                  .softButtonStyle(
                    Circle(),
                    pressedEffect: .flat
                  )
                  .padding(.leading)
                  Text("DecryptKit's IPA Repository")
                    .font(.callout)
                    .fontWeight(.semibold)
                    .padding(.leading)
                }
                List {
                  ForEach(sourceData ?? [], id: \.bundleID) { app in
                    RepoAppDetails(appBundleID: app.bundleID, appName: app.name, appVersion: app.version)
                  }
                  .listRowBackground(mainColor)
                }
                .listStyle(.plain)
              }
            }
        }
      }
    }
  }
}
