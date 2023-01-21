//
//  Components.swift
//  deCripple
//
//  Created by Amir Mohammadi on 9/10/1401 AP.
//

import SwiftUI
import Neumorphic
import RealmSwift

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

// MARK: - DecryptKit People
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
        Text("Contributors:")
          .font(.subheadline)
          .padding(.top)
        Group {
          Text("Depal#7088")
            .padding(.top, 1)
          Text("Zhich#6244")
        }
        .font(.subheadline.monospaced())
      }
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
