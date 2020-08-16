//
//  UserSettings.swift
//  piny
//
//  Created by John Grishin on 05/08/2020.
//  Copyright © 2020 John Grishin. All rights reserved.
//

import SwiftUI

struct UserSettings: View {
  @EnvironmentObject var userState: UserState

  func logout() {
    userState.logout().catch { error in
      Piny.log(error, .error)
    }
  }

  var body: some View {
    List {
      Section {
        HStack {
          Text("Name")
          Spacer()
          Text(self.userState.user?.name ?? "—")
        }
        HStack {
          Text("Email")
          Spacer()
          Text(self.userState.user?.email ?? "—")
        }
      }
      Section {
        Button(action: logout) {
          Text("Log Out")
        }
      }
    }
    .listStyle(GroupedListStyle())
  }
}

struct UserSettings_Previews: PreviewProvider {
  static var previews: some View {
    UserSettings()
  }
}
