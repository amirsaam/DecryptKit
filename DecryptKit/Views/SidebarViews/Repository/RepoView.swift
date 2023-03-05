//
//  RepoView.swift
//  deCripple
//
//  Created by Amir Mohammadi on 9/10/1401 AP.
//

import SwiftUI
import Neumorphic

// MARK: - View Struct
struct RepoView: View {

  @Binding var showRepo: Bool
  @Namespace var animation

  @State private var freeSourceData = SourceVM.shared.freeSourceData
  @State private var vipSourceData = SourceVM.shared.vipSourceData
  @State private var selectedSource: SourceTabs = .free
  @State private var progressAmount = 0.0

  // MARK: - View Body
  var body: some View {
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
                    (freeSourceData, vipSourceData) = (nil, nil)
                    URLCache.shared.removeAllCachedResponses()
                    try? await Task.sleep(nanoseconds: 4000000000)
                    await resolveSourceData()
                    freeSourceData = SourceVM.shared.freeSourceData
                    vipSourceData = SourceVM.shared.vipSourceData
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
              ZStack {
                Capsule()
                  .fill(mainColor)
                  .frame(height: 45)
                  .softInnerShadow(
                    Capsule(),
                    radius: 2.5
                  )
                  .padding(.horizontal, 10)
                HStack {
                  ForEach(SourceTabs.allCases, id: \.rawValue) { source in
                    ZStack {
                      if selectedSource == source {
                        Capsule()
                          .fill(mainColor)
                          .frame(height: 30)
                          .matchedGeometryEffect(id: "source", in: animation)
                          .softOuterShadow(offset: 2)
                      } else {
                        Capsule()
                          .foregroundColor(.clear)
                          .frame(height: 30)
                      }
                      HStack {
                        Image(systemName: source.icon)
                        Text(source.title)
                          .fontWeight(selectedSource == source ? .semibold : .regular)
                      }
                      .font(.subheadline)
                      .foregroundColor(selectedSource == source ? secondaryColor : .gray)
                    }
                    .onTapGesture {
                      withAnimation(.easeInOut) {
                        selectedSource = source
                      }
                    }
                  }
                }
                .padding(.horizontal)
              }
              .padding(.top)
              TabView(selection: $selectedSource) {
                FreeSourceList(freeSourceData: $freeSourceData,
                               progressAmount: $progressAmount)
                .padding(.top)
                .tag(SourceTabs.free)
                VIPSourceList(vipSourceData: $vipSourceData,
                              progressAmount: $progressAmount)
                .padding(.top)
                .tag(SourceTabs.vip)
              }
              .tabViewStyle(.page(indexDisplayMode: .never))
            }
          }
      }
    }
    .task {
      if freeSourceData == nil || vipSourceData == nil {
        await resolveSourceData()
      }
      freeSourceData = SourceVM.shared.freeSourceData
      vipSourceData = SourceVM.shared.vipSourceData
    }
  }
}

// MARK: - SourceTabs Enum & Data
enum SourceTabs: Int, CaseIterable {
  case free, vip
  
  var title: String {
    switch self {
    case .free: return "Public Source"
    case .vip: return "VIP Source"
    }
  }

  var icon: String {
    switch self {
    case .free: return "globe.desk.fill"
    case .vip: return "crown.fill"
    }
  }
}

// MARK: - Public Source ListView
struct FreeSourceList: View {
  @Binding var freeSourceData: [deCrippleSource]?
  @Binding var progressAmount: Double

  @State private var isSelected: Set<deCrippleSource> = []
  @State private var linkCopied = false

  var body: some View {
    List {
      if freeSourceData == nil {
        LoadingSourceView(progressAmount: $progressAmount)
          .listRowBackground(mainColor)
      }
      ForEach(freeSourceData ?? [], id: \.bundleID) { app in
        RepoAppDetails(appBundleID: app.bundleID,
                       appName: app.name,
                       appVersion: app.version)
        .onTapGesture {
          withAnimation {
            if UserVM.shared.userTier >= 1 {
              selectDeselect(app)
            }
          }
        }
        if isSelected.contains(app) {
          ZStack {
            Rectangle()
              .fill(mainColor)
              .softInnerShadow(
                Rectangle(),
                radius: 2.5
              )
              .frame(height: 45)
              .overlay {
                HStack {
                  Spacer()
                  Button {
                    UIPasteboard.general.string = app.link
                    withAnimation {
                      linkCopied = true
                    }
                  } label: {
                    HStack(spacing: 10) {
                      Image(systemName: linkCopied ? "checkmark.circle.fill" : "doc.on.doc.fill")
                      Text(linkCopied ? "Download Link Copied to Clipboard" : "Click to Copy Download Link to Clipboard")
                    }
                    .font(.caption)
                  }
                  Spacer()
                }
                .onChange(of: linkCopied) { bool in
                  if bool {
                    Task {
                      try? await Task.sleep(nanoseconds: 4000000000)
                      withAnimation {
                        linkCopied = false
                      }
                    }
                  }
                }
              }
          }
          .listRowInsets(
            .init(
              top: 0,
              leading: 0,
              bottom: 0,
              trailing: 0)
          )
        }
      }
      .listRowBackground(mainColor)
    }
    .listStyle(.plain)
  }
  
  private func selectDeselect(_ app: deCrippleSource) {
    if isSelected.contains(app) {
      isSelected.remove(app)
    } else {
      isSelected.removeAll()
      linkCopied = false
      isSelected.insert(app)
    }
  }
}

// MARK: - VIP Source ListView
struct VIPSourceList: View {
  @Binding var vipSourceData: [deCrippleSource]?
  @Binding var progressAmount: Double

  @State private var isSelected: Set<deCrippleSource> = []
  @State private var linkCopied = false

  var body: some View {
    List {
      if vipSourceData == nil {
        LoadingSourceView(progressAmount: $progressAmount)
          .listRowBackground(mainColor)
      } else {
        if UserVM.shared.userTier < 2 {
          Label("Subscribe to Partron to use VIP source!", systemImage: "exclamationmark.triangle.fill")
            .font(.subheadline)
            .foregroundColor(.red)
            .listRowBackground(mainColor)
        } else {
          Label("VIP source is available to use for you!", systemImage: "checkmark.diamond.fill")
            .font(.subheadline)
            .foregroundColor(.green)
            .listRowBackground(mainColor)
        }
      }
      ForEach(vipSourceData ?? [], id: \.bundleID) { app in
        RepoAppDetails(appBundleID: app.bundleID,
                       appName: app.name,
                       appVersion: app.version)
        .onTapGesture {
          withAnimation {
            if UserVM.shared.userTier >= 3 {
              selectDeselect(app)
            }
          }
        }
        if isSelected.contains(app) {
          ZStack {
            Rectangle()
              .fill(mainColor)
              .softInnerShadow(
                Rectangle(),
                radius: 2.5
              )
              .frame(height: 45)
              .overlay {
                HStack {
                  Spacer()
                  Button {
                    UIPasteboard.general.string = app.link
                    withAnimation {
                      linkCopied = true
                    }
                  } label: {
                    HStack(spacing: 10) {
                      Image(systemName: linkCopied ? "checkmark.circle.fill" : "doc.on.doc.fill")
                      Text(linkCopied ? "Download Link Copied to Clipboard" : "Click to Copy Download Link to Clipboard")
                    }
                    .font(.caption)
                  }
                  Spacer()
                }
                .onChange(of: linkCopied) { bool in
                  if bool {
                    Task {
                      try? await Task.sleep(nanoseconds: 4000000000)
                      withAnimation {
                        linkCopied = false
                      }
                    }
                  }
                }
              }
          }
          .listRowInsets(
            .init(
              top: 0,
              leading: 0,
              bottom: 0,
              trailing: 0)
          )
        }
      }
      .listRowBackground(mainColor)
    }
    .listStyle(.plain)
  }
  
  private func selectDeselect(_ app: deCrippleSource) {
    if isSelected.contains(app) {
      isSelected.remove(app)
    } else {
      isSelected.removeAll()
      linkCopied = false
      isSelected.insert(app)
    }
  }
}

// MARK: - Loading Sources ProgressView
struct LoadingSourceView: View {
  @Binding var progressAmount: Double
  let timer = Timer.publish(every: 0.1, on: .main, in: .common).autoconnect()
  var body: some View {
    HStack {
      Spacer()
      ProgressView("Loading...", value: progressAmount, total: 100)
        .progressViewStyle(.linear)
        .onReceive(timer) { _ in
          if progressAmount < 100 {
            progressAmount += 2.5
          }
        }
      Spacer()
    }
  }
}
