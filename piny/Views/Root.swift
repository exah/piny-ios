//
//  Root.swift
//  piny
//
//  Created by John Grishin on 16/07/2020.
//  Copyright © 2020 John Grishin. All rights reserved.
//

import SwiftUI

struct Root: View {
  static let storage = Storage("piny")
  @EnvironmentObject var userState: UserState
  
  var body: some View {
    NavigationView {
      Group {
        if userState.user?.token != nil {
          PinList()
        } else {
          LogIn()
        }
      }
      .navigationBarTitle("Piny")
    }
  }
}

struct Root_Previews: PreviewProvider {
  static var previews: some View {
    Root().environmentObject(UserState())
  }
}
