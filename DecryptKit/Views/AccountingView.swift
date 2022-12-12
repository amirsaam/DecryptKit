//
//  AccountingView.swift
//  deCripple
//
//  Created by Amir Mohammadi on 9/17/1401 AP.
//

import SwiftUI
import Neumorphic
import RealmSwift

/// Log in or register users using email/password authentication
struct AccountingView: View {
  
  @ObservedResults(deUser.self) var user
  @State var newUser = deUser()

  @State var email = ""
  @State var emailIsValid: Bool = false
  @State var emailAttempts: Int = 0  
  @State var password = ""

  @State var hasAccount = true
  @State var showProgress = false
  @State var error: Error?

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
            VStack(spacing: geo.size.width * (0.25/10)) {
              VStack(alignment: .leading) {
                Text("Thank you for choosing DecryptKit")
                  .font(.title.monospaced())
                Text("Our IPA decryption service sends download links of your requsts only via email so make sure to enter a valid and available address when you are creating an account!")
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
              HStack {
                if let error = error {
                  ErrorMessage(errorLog: error.localizedDescription)
                }
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
                  Text(hasAccount == true ? "Don't have an Account?" : "Already have an account?")
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
                  Label(hasAccount == true ? "Sign in" : "Sign up", systemImage: hasAccount == true ? "key.fill" : "plus")
                    .frame(width: 100)
                }
                .softButtonStyle(
                  RoundedRectangle(cornerRadius: 15),
                  mainColor: .red,
                  textColor: .white,
                  darkShadowColor: .redNeuDS,
                  lightShadowColor: .redNeuLS,
                  pressedEffect: .flat
                )
                .disabled(showProgress)
              }
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
  /// Logs in with an existing user.
  func login(email: String, password: String) async {
    do {
      let user = try await realmApp.login(credentials: Credentials.emailPassword(email: email, password: password))
      print("Successfully logged in user: \(user)")
      newUser.userId = user.id
      newUser.userEmail = email
      $user.append(newUser)
    } catch {
      print("Failed to log in user: \(error.localizedDescription)")
      self.error = error
    }
  }
  /// Registers a new user with the email/password authentication provider.
  func signUp(email: String, password: String) async {
    do {
      try await realmApp.emailPasswordAuth.registerUser(email: email, password: password)
      print("Successfully registered user")
      await login(email: email, password: password)
    } catch {
      print("Failed to register user: \(error.localizedDescription)")
      self.error = error
    }
  }
}


/// Logout from the synchronized realm. Returns the user to the login/sign up screen.
struct RealmLogoutError: Identifiable {
  let id = UUID()
  let errorText: String
}

struct LogoutButton: View {
  @State var isLoggingOut = false
  @State var error: Error?
  @State var errorMessage: RealmLogoutError? = nil
  
  var body: some View {
    HStack {
      Button("Sign out") {
        guard let user = realmApp.currentUser else {
          return
        }
        isLoggingOut = true
        Task {
          await logout(user: user)
          // Other views are observing the app and will detect
          // that the currentUser has changed. Nothing more to do here.
          isLoggingOut = false
        }
      }
      .disabled(realmApp.currentUser == nil || isLoggingOut)
      // Show an alert if there is an error during logout
      .alert(item: $errorMessage) { errorMessage in
        Alert(
          title: Text("Failed to log out"),
          message: Text(errorMessage.errorText),
          dismissButton: .cancel()
        )
      }
      if isLoggingOut {
        ProgressView()
          .padding(.leading)
      }
    }
  }
  /// Asynchronously log the user out, or display an alert with an error if logout fails.
  func logout(user: User) async {
    do {
      try await user.logOut()
      print("Successfully logged user out")
    } catch {
      print("Failed to log user out: \(error.localizedDescription)")
      // SwiftUI Alert requires the item it displays to be Identifiable.
      // Optional Error is not Identifiable.
      // Store the error as errorText in our Identifiable ErrorMessage struct,
      // which we can display in the alert.
      self.errorMessage = RealmLogoutError(errorText: error.localizedDescription)
    }
  }
}
