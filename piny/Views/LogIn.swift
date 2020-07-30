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
      log(error, .error)
    }
  }

  var body: some View {
    VStack(spacing: 32) {
      Group {
        TextField("User", text: $name)
        SecureField("Password", text: $pass)
      }
        .font(.system(size: 18))
        .textFieldStyle(RoundedBorderTextFieldStyle())
        .autocapitalization(.none)
  
      if userState.isLoading {
        Text("Loading...")
      } else {
        Button("Login", action: handleLogin)
      }

      Spacer()
    }
    .padding(16)
  }
}

struct Login_Previews: PreviewProvider {
  static var previews: some View {
    LogIn()
      .environmentObject(UserState())
  }
}
