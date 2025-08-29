//
//  Root.swift
//  piny
//
//  Created by John Grishin on 16/07/2020.
//  Copyright © 2020 John Grishin. All rights reserved.
//

import SwiftUI
import SwiftData

struct Root: View {
  @Environment(AsyncUser.self) var asyncUser
  @Query var users: [User]

  var isLoggedIn: Bool { users.first?.token != nil }

  var body: some View {
    Group {
      if isLoggedIn {
        UserTabs()
      } else {
        LogIn()
      }
    }.onChange(of: users) {

    }
  }
}

struct Root_Previews: PreviewProvider {
  static var previews: some View {
    Root()
      .environment(AsyncUser())
      .environment(AsyncPins())
  }
}
