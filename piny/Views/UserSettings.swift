//
//  UserSettings.swift
//  piny
//
//  Created by John Grishin on 05/08/2020.
//  Copyright © 2020 John Grishin. All rights reserved.
//

import SwiftData
import SwiftUI

struct UserSettings: View {
  @Environment(AsyncUser.self)
  var asyncUser
  @Query
  var users: [User]
  @Query
  var sessions: [Session]

  var user: User? { users.first }
  var session: Session? { sessions.first }

  func logout() {
    Task {
      do {
        try await asyncUser.logout()
      } catch {
        Piny.log(error, .error)
      }
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
          Text(session?.token ?? "—")
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
