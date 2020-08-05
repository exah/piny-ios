//
//  Root.swift
//  piny
//
//  Created by John Grishin on 16/07/2020.
//  Copyright © 2020 John Grishin. All rights reserved.
//

import SwiftUI

struct Root: View {
  @EnvironmentObject var userState: UserState
  
  var body: some View {
    Group {
      if userState.isLoggedIn {
        UserTabs()
      } else {
        LogIn()
      }
    }
  }
}

struct Root_Previews: PreviewProvider {
  static var previews: some View {
    Root()
      .environmentObject(UserState())
      .environmentObject(PinsState())
  }
}
