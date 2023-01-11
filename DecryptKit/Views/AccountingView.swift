//
//  AccountingView.swift
//  deCripple
//
//  Created by Amir Mohammadi on 9/17/1401 AP.
//

import SwiftUI
import Neumorphic
import RealmSwift

// MARK: - Sign In/Up View Struct
/// Log in or register users using email/password authentication
struct AccountingView: View {

  @EnvironmentObject var errorHandler: ErrorHandler

  @State private var email = ""
  @State private var emailIsValid = false
  @State private var emailAttempts = 0
  @State private var password = ""

  @State private var hasAccount = true
  @State private var showProgress = false
  @State private var error: Error?

// MARK: - Sign In/Up View Body
  var body: some View {
    ZStack {
      mainColor
        .ignoresSafeArea(.all)
      GeometryReader { geo in
        VStack {
          Spacer()
          HStack(alignment: .center, spacing: geo.size.width * (0.25/10)) {
            Spacer()
            BrandInfo(logoSize: geo.size.width * (2/10))
            VStack(alignment: .leading, spacing: geo.size.width * (0.25/10)) {
              VStack(alignment: .leading) {
                Text("Thank you for choosing DecryptKit")
                  .font(.title.monospaced())
                  .padding(.bottom)
                Text("Our IPA decryption service sends download links for your requsts only via email, so make sure to enter a valid and available address when you are creating an account!")
                  .font(.subheadline.italic())
                  .padding(.top)
              }
              VStack {
                TextField("Email Address", text: $email)
                  .modifier(Shake(animatableData: CGFloat(emailAttempts)))
                  .textInputAutocapitalization(.never)
                  .autocorrectionDisabled(true)
                Divider()
                SecureField("Password", text: $password)
              }
              .padding(.top, 50)
              HStack {
                Spacer()
                if showProgress {
                  ProgressView()
                    .padding(.trailing)
                }
                Button {
                  withAnimation {
                    hasAccount.toggle()
                  }
                } label: {
                  Text(hasAccount ? "Don't have an Account?" : "Already have an account?")
                    .font(.footnote)
                    .foregroundColor(secondaryColor)
                }
                .disabled(showProgress)
                .padding(.trailing)
                Button {
                  emailIsValid = isValidEmailAddress(emailAddressString: email)
                  if email.isEmpty || !emailIsValid {
                    withAnimation(.default) {
                      self.emailAttempts += 1
                    }
                  } else {
                    showProgress = true
                    switch hasAccount {
                    case true:
                      Task.init {
                        await login(email: email, password: password)
                        showProgress = false
                      }
                    case false:
                      Task {
                        await signUp(email: email, password: password)
                        showProgress = false
                      }
                    }
                  }
                } label: {
                  Label(hasAccount ? "Sign in" : "Sign up",
                        systemImage: hasAccount ? "key.fill" : "plus")
                    .frame(width: 100)
                }
                .softButtonStyle(
                  RoundedRectangle(cornerRadius: 15),
                  padding: 10,
                  mainColor: .red,
                  textColor: .white,
                  darkShadowColor: .redNeuDS,
                  lightShadowColor: .redNeuLS,
                  pressedEffect: .flat
                )
                .disabled(showProgress)
              }
              .padding(.top)
            }
            Creators()
              .frame(width: geo.size.width * (2/10))
            Spacer()
          }
          Spacer()
        }
        .padding()
      }
    }
  }
// MARK: Sign In Function
  func login(email: String, password: String) async {
    defaults.set(email, forKey: "Email")
    do {
      let user = try await realmApp.login(credentials: Credentials.emailPassword(email: email, password: password))
      debugPrint("Successfully logged in user: \(user)")
    } catch {
      debugPrint("Failed to log in user: \(error.localizedDescription)")
      errorHandler.error = error
    }
  }
// MARK: Sign Up Function
  func signUp(email: String, password: String) async {
    do {
      try await realmApp.emailPasswordAuth.registerUser(email: email, password: password)
      debugPrint("Successfully registered user")
      await login(email: email, password: password)
    } catch {
      debugPrint("Failed to register user: \(error.localizedDescription)")
      errorHandler.error = error
    }
  }
}

// MARK: Sign Out View Struct
/// Logout from the synchronized realm. Returns the user to the login/sign up screen.
struct SignOutButton: View {

  @State var isSigningOut = false
  @State var error: Error?
  @State var errorMessage: RealmSignOutError? = nil
  
  var body: some View {
    HStack {
      Button {
        guard let user = realmApp.currentUser else {
          return
        }
        isSigningOut = true
        Task {
          await logout(user: user)
          isSigningOut = false
        }
      } label: {
        Text("Sign out")
          .font(.footnote)
          .textCase(.uppercase)
      }
      .disabled(realmApp.currentUser == nil || isSigningOut)
      .alert(item: $errorMessage) { errorMessage in
        Alert(
          title: Text("Failed to log out"),
          message: Text(errorMessage.errorText),
          dismissButton: .cancel()
        )
      }
      if isSigningOut {
        ProgressView()
          .padding(.leading)
      }
    }
  }
// MARK: - Sign Out Function
  func logout(user: User) async {
    do {
      try await user.logOut()
      debugPrint("Successfully logged user out")
    } catch {
      debugPrint("Failed to log user out: \(error.localizedDescription)")
      self.errorMessage = RealmSignOutError(errorText: error.localizedDescription)
    }
  }
}

// MARK: - Sign Out Errors
struct RealmSignOutError: Identifiable {
  let id = UUID()
  let errorText: String
}
