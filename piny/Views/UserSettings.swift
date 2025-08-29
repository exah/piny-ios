//
//  UserSettings.swift
//  piny
//
//  Created by John Grishin on 05/08/2020.
//  Copyright © 2020 John Grishin. All rights reserved.
//

import SwiftUI
import SwiftData

struct UserSettings: View {
  @Environment(AsyncUser.self) var asyncUser
  @Query var users: [User]

  var user: User? { users.first }

  func logout() {
    asyncUser.logout().catch { error in
      Piny.log(error, .error)
    }
  }

  var body: some View {
    List {
      Section {
        HStack {
          Text("Name")
          Spacer()
          Text(user?.name ?? "—")
        }
        HStack {
          Text("Email")
          Spacer()
          Text(user?.email ?? "—")
        }
        HStack {
          Text("Token")
          Spacer()
          Text(user?.token ?? "—")
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
