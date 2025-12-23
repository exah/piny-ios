//
//  Root.swift
//  piny
//
//  Created by John Grishin on 16/07/2020.
//  Copyright © 2020 John Grishin. All rights reserved.
//

import SwiftData
import SwiftUI

struct Root: View {
  @Query
  var sessions: [Session]
  var isLoggedIn: Bool { sessions.last?.token != nil }

  var body: some View {
    Group {
      if isLoggedIn {
        UserTabs()
      } else {
        LogIn()
      }
    }
  }
}

#Preview {
  Root()
}
