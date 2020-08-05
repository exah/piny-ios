//
//  Tabs.swift
//  piny
//
//  Created by John Grishin on 05/08/2020.
//  Copyright © 2020 John Grishin. All rights reserved.
//

import SwiftUI

struct UserTabs: View {
  var body: some View {
    TabView {
      NavigationView {
        UserPinList()
          .navigationBarTitle("Piny")
      }
      .tabItem {
        Image(systemName: "pin.fill")
        Text("All")
      }
      NavigationView {
        UserSettings()
          .navigationBarTitle("Settings")
      }
      .tabItem {
        Image(systemName: "gear")
        Text("Settings")
      }
    }
  }
}

struct Tabs_Previews: PreviewProvider {
  static var previews: some View {
    UserTabs()
  }
}
