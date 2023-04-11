//
//  Components.swift
//  deCripple
//
//  Created by Amir Mohammadi on 9/10/1401 AP.
//

import SwiftUI
import Neumorphic

// MARK: - DecryptKit Branding
struct BrandInfo: View {
  @State var logoSize: CGFloat
  @State private var isRotating = 0.0
  var body: some View {
    VStack {
      VStack(alignment: .center) {
        Image("deCripple")
          .resizable()
          .aspectRatio(contentMode: .fit)
          .frame(width: logoSize, height: logoSize)
          .rotationEffect(.degrees(isRotating))
          .softOuterShadow()
          .onAppear {
            withAnimation(
              .linear(duration: 1)
              .speed(0.1)
              .repeatForever(autoreverses: false)
            ) {
              isRotating = 360.0
            }
          }
        Group {
          Text("DecryptKit")
            .font(.largeTitle.monospaced())
            .fontWeight(.bold)
          Text("repo.DecryptKit.xyz")
            .font(.title2.lowercaseSmallCaps())
            .fontWeight(.regular)
        }
        .foregroundColor(.invertNeuPC)
      }
      .softOuterShadow()
    }
  }
}

// MARK: - DecryptKit ProgressView
struct BrandProgress: View {
  @State var logoSize: CGFloat
  @State var progressText: String?
  @State private var isRotating = 0.0
  var body: some View {
    VStack {
      Image("deCripple")
        .resizable()
        .aspectRatio(contentMode: .fit)
        .frame(width: logoSize, height: logoSize)
        .rotationEffect(.degrees(isRotating))
        .softOuterShadow()
        .onAppear {
          withAnimation(
            .linear(duration: 1)
            .speed(0.2)
            .repeatForever(autoreverses: false)
          ) {
            isRotating = 360.0
          }
        }
      Text(progressText ?? "")
        .font(.caption.monospaced())
        .textCase(.uppercase)
    }
  }
}

// MARK: - Restricted User View
struct RestrictedUser: View {
  var body: some View {
    HStack {
      Spacer()
      VStack {
        Spacer()
        Text("This account has been Restricted!")
          .font(.title.monospaced())
        Text("support@decryptkit.xyz")
          .font(.headline.monospaced())
          .padding(.top)
        Text("Contact above Email Address for more Information")
          .font(.headline.monospaced())
          .padding(.top, 1)
        Spacer()
      }
      Spacer()
    }
  }
}

// MARK: - Sidebar Views Background
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

// MARK: -
struct NoPlayCoverAlert: ViewModifier {
  @Binding var noPlayCover: Bool
    func body(content: Content) -> some View {
        content
        .alert("PlayCover is not Installed!", isPresented: $noPlayCover) {
          Button("Install PlayCover", role: .none) {
            if let url = URL(string: "https://github.com/PlayCover/PlayCover/releases") {
              UIApplication.shared.open(url)
              if UpdaterVM.shared.upstreamIsCritical {
                exit(0)
              }
            }
          }
          Button("Cancel", role: .cancel) {
            if UpdaterVM.shared.upstreamIsCritical {
              exit(0)
            } else {
              return
            }
          }
        } message: {
          Text("It is a requirement to have PlayCover installed for utilization of DecryptKit IPA Sources or App Updates.")
        }
    }
}


struct AdView: View {
  var body: some View {
    Button {

    } label: {
      Text("Advertisement Banner Placeholder")
        .padding(.horizontal)
    }
    .softButtonStyle(
      RoundedRectangle(cornerRadius: 15),
      pressedEffect: .flat
    )
  }
}

// MARK: - DecryptKit Errors
struct ErrorMessage: View {
  @State var errorLog: String
  var body: some View {
    Text(errorLog)
      .font(.subheadline)
      .foregroundColor(.red)
  }
}

// MARK: - Realm Errors
struct RealmError: View {
    @State var error: Error
    var body: some View {
        Text("Error: \(error.localizedDescription)")
    }
}
