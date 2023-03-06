//
//  Login.swift
//  piny
//
//  Created by John Grishin on 16/07/2020.
//  Copyright © 2020 John Grishin. All rights reserved.
//

import SwiftUI

struct LogIn: View {
  @EnvironmentObject var userState: UserState
  @State private var name: String = ""
  @State private var pass: String = ""
  @State private var email: String = ""
  @State private var shouldSignUp: Bool = false
  
  func handleLogin() {
    self.userState.login(
      name: name,
      pass: pass
    ).catch { error in
      if let error = error as? API.Error {
        switch error {
          case .notOK( _, let statusCode, _): do {
            if statusCode == 404 {
              self.shouldSignUp = true
            }
          }
          default:
            Piny.log(error, .error)
        }
      }
    }
  }

  func handleSignUp() {
    self.userState.signUp(
      name: name,
      pass: pass,
      email: email
    ).catch { error in
      Piny.log(error, .error)
    }
  }

  var body: some View {
    NavigationView {
      ZStack {
        Color(red: 0.93, green: 0.93, blue: 0.93)
          .edgesIgnoringSafeArea(.all)
        VStack {
          VStack(spacing: 24) {
            VStack(spacing: 12) {
              Image("Logo")
              Text("Welcome 👋")
                .variant(.secondary)
                .foregroundColor(.gray)
            }
            VStack(spacing: 12) {
              Group {
                Input("Username", value: $name)
                Input("Password", type: .password, value: $pass)
              }
              .autocapitalization(.none)
              .autocorrectionDisabled()
            }
            Button(action: handleLogin) {
              Text(userState.isLoading ? "Loading..." : "Login")
                .frame(maxWidth: .infinity)
            }
            .variant(.black)
            .disabled(userState.isLoading)
            .alert(
              "Enter your email to create an account",
              isPresented: $shouldSignUp
            ) {
              TextField("Email", text: $email)
              Button("Create account", action: handleSignUp)
              Button("Cancel", role: .cancel, action: {
                email = ""
                shouldSignUp.toggle()
              })
            }
          }
          .padding(32)
          .background(Color.white)
          .shadow(color: Color.black.opacity(0.08), radius: 48)
          .cornerRadius(40)
        }
        .padding(.horizontal, 12)
      }
    }
  }
}

struct Login_Previews: PreviewProvider {
  static var previews: some View {
    LogIn()
      .environmentObject(UserState())
  }
}
