//
//  Tabs.swift
//  piny
//
//  Created by John Grishin on 05/08/2020.
//  Copyright © 2020 John Grishin. All rights reserved.
//

import SwiftUI

struct UserTabs: View {
  @State
  var search: String = ""

  var body: some View {
    TabView {
      Tab("All", image: "icons.16.all") {
        NavigationStack {
          UserPinList()
            .navigationBarTitle("All")
            .toolbar {
              ToolbarItem(placement: .largeTitle) {
                Image("assets.logo").padding(.bottom, 16)
              }
            }
        }
      }
      Tab("Settings", image: "icons.16.settings") {
        UserSettings()
          .navigationBarTitle("Settings")
      }
      Tab(role: .search) {
        NavigationStack {
          VStack {
            // TODO: Add view of all tags
          }
          .navigationTitle("Search")
        }
      }
    }
    .tabViewStyle(.sidebarAdaptable)
    .searchable(text: $search)
  }
}

#Preview {
  UserTabs()
}
