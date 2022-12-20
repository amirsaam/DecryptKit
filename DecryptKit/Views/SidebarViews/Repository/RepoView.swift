//
//  RepoView.swift
//  deCripple
//
//  Created by Amir Mohammadi on 9/10/1401 AP.
//

import SwiftUI
import Neumorphic
import DataCache

struct RepoView: View {

  @Binding var showRepo: Bool
  @Binding var sourceData: [deCrippleSource]?

  @State var doRefresh = false

  var body: some View {
    GeometryReader { geo in
      ZStack {
        if showRepo {
          SidebarBackground()
            .overlay {
              VStack(alignment: .leading) {
                HStack(alignment: .center) {
                  Button {
                    withAnimation(.spring()) {
                      showRepo = false
                    }
                  } label: {
                    Image(systemName: "chevron.compact.right")
                  }
                  .softButtonStyle(
                    Circle(),
                    padding: 13,
                    pressedEffect: .flat
                  )
                  .padding(.leading)
                  Spacer()
                  Text("DecryptKit IPA Repository")
                    .font(.footnote.monospaced())
                    .fontWeight(.semibold)
                    .softOuterShadow()
                  Spacer()
                  Button {
                    sourceData = nil
                    DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                      Task {
                        await resolveSourceData()
                        sourceData = try DataCache.instance.readCodable(forKey: "cachedSourceData")
                        doRefresh = true
                      }
                    }
                  } label: {
                    Image(systemName: "arrow.clockwise")
                  }
                  .softButtonStyle(
                    Circle(),
                    padding: 8,
                    pressedEffect: .flat
                  )
                  Spacer()
                }
                .padding(.top)
                List {
                  if sourceData == nil {
                    HStack {
                      Spacer()
                      ProgressView("Loading...")
                        .progressViewStyle(.linear)
                      Spacer()
                    }
                    .listRowBackground(mainColor)
                  }
                  ForEach(sourceData ?? [], id: \.bundleID) { app in
                    RepoAppDetails(doRefresh: $doRefresh,
                                   appBundleID: app.bundleID,
                                   appName: app.name,
                                   appVersion: app.version)
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
