//
//  Login.swift
//  piny
//
//  Created by John Grishin on 16/07/2020.
//  Copyright © 2020 John Grishin. All rights reserved.
//

import SwiftUI
import PromiseKit

struct LogIn: View {
  @Environment(AsyncUser.self) var asyncUser
  @State private var name: String = ""
  @State private var pass: String = ""
  @State private var email: String = ""
  @State private var shouldSignUp: Bool = false
  
  func handleLogin() {
    self.asyncUser.login(
      name: name,
      pass: pass
    ).catch { error in
      if let error = error as? API.Error {
        switch error {
          case .notOK( _, let statusCode, _, _): do {
            if statusCode == 404 {
              self.shouldSignUp = true
            }
          }
          default:
            Piny.log(error, .error)
        }
      }

      return
    }
  }

  func handleSignUp() {
    self.asyncUser.signUp(
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
        Color.piny.background
          .edgesIgnoringSafeArea(.all)
        VStack {
          VStack(spacing: 24) {
            VStack(spacing: 12) {
              Image("assets.logo")
                .renderingMode(.template)
                .foregroundColor(.piny.foreground)
              Text("Welcome 👋")
                .variant(.secondary)
                .foregroundColor(.piny.grey50)
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
              Group {
                if (asyncUser.isLoading) {
                  Image(systemName: "circle.dotted")
                } else {
                  Text("Login")
                }
              }.frame(maxWidth: .infinity)
            }
            .variant(.primary)
            .disabled(asyncUser.isLoading)
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
          .background(Color.piny.level48)
          .cornerRadius(40)
          .shadow(color: .piny.black.opacity(0.08), radius: 48)
        }
        .padding(.horizontal, 12)
      }
    }
  }
}

struct Login_Previews: PreviewProvider {
  static var previews: some View {
    LogIn()
      .environment(AsyncUser())
  }
}
