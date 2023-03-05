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
  
  func handleLogin() {
    self.userState.login(
      name: name,
      pass: pass
    ).catch { error in
      if let error = error as? API.Error {
        switch error {
          case .notOK( _, let statusCode, _): do {
            if statusCode == 404 {
              self.signUpAlert { email in
                self.handleSignUp(email)
              }
            }
          }
          default:
            Piny.log(error, .error)
        }
      }
    }
  }

  func handleSignUp(_ email: String) {
    self.userState.signUp(
      name: name,
      pass: pass,
      email: email
    ).catch { error in
      Piny.log(error, .error)
    }
  }

  private func signUpAlert(action: @escaping (_ email: String) -> Void) {
    guard let controller = UIApplication.shared.windows[0].rootViewController else {
      return
    }

    let alert = UIAlertController(
      title: "👋 Welcome",
      message: "Enter your email to create an account",
      preferredStyle: .alert
    )

    alert.addTextField { textField in
      textField.placeholder = "Email"
    }

    alert.addAction(UIAlertAction(title: "Create account", style: .default) { _ in
      if let text = alert.textFields?[0].text {
        action(text)
      }
    })

    alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
    controller.present(alert, animated: true)
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
                .variant(.secondary, color: .gray)
            }
            VStack(spacing: 12) {
              Group {
                TextField("Username", text: $name)
                SecureField("Password", text: $pass)
              }
              .textFieldStyle(ShapedTextFieldStyle())
              .autocapitalization(.none)
              .autocorrectionDisabled()
            }
            Button(action: handleLogin) {
              Text(userState.isLoading ? "Loading..." : "Login")
                .padding(.horizontal, 4)
                .frame(maxWidth: .infinity)
            }
            .variant(.black)
            .disabled(userState.isLoading)
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
