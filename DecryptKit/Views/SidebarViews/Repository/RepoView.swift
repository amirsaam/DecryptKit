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

  @State private var progressAmount = 0.0
  let timer = Timer.publish(every: 0.1, on: .main, in: .common).autoconnect()

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
                    Task {
                      progressAmount = 0
                      sourceData = nil
                      cache.clean(byKey: "cachedSourceData")
                      try? await Task.sleep(nanoseconds: 5000000000)
                      await resolveSourceData()
                      sourceData = try? cache.readCodable(forKey: "cachedSourceData")
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
                      ProgressView("Loading...", value: progressAmount, total: 100)
                        .progressViewStyle(.linear)
                        .onReceive(timer) { _ in
                          if progressAmount < 100 {
                            progressAmount += 2
                          }
                        }
                      Spacer()
                    }
                    .listRowBackground(mainColor)
                  }
                  ForEach(sourceData ?? [], id: \.bundleID) { app in
                    RepoAppDetails(appBundleID: app.bundleID,
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
