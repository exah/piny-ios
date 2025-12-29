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
  @Environment(SessionState.self)
  var sessionState

  @Query(UserActor.Descriptors.all())
  var users: [UserModel]
  var user: UserModel? { users.last }

  func logout() {
    Task {
      do {
        try await sessionState.logout()
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

#Preview {
  UserSettings()
}
