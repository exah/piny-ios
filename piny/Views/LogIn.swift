//
//  Login.swift
//  piny
//
//  Created by John Grishin on 16/07/2020.
//  Copyright © 2020 John Grishin. All rights reserved.
//

import SwiftUI

struct LogIn: View {
  @EnvironmentObject var userData: UserData

  @State private var isLoading: Bool = false
  @State private var user: String = ""
  @State private var pass: String = ""
  
  func handleLogin() {
    print("Login... user: \(user) / pass: \(pass)")
    
    self.isLoading = true
    self.userData.login(
      user: user,
      pass: pass
    ) {
      print("Welcome 👋")
      self.isLoading = false
    }
  }
  
  var body: some View {
    VStack(spacing: 32) {
      Group {
        TextField("User", text: $user)
        SecureField("Password", text: $pass)
      }
        .font(.system(size: 18))
        .textFieldStyle(RoundedBorderTextFieldStyle())
        .autocapitalization(.none)
  
      if isLoading {
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
      .environmentObject(UserData())
  }
}
