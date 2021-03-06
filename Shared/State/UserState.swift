//
//  UserData.swift
//  piny
//
//  Created by John Grishin on 14/07/2020.
//  Copyright © 2020 John Grishin. All rights reserved.
//

import Foundation
import PromiseKit
import UIKit

final class UserState: AsyncState {
  @Published var user: User?
  @Published var isLoading: Bool = false

  var isLoggedIn: Bool { user?.token != nil }

  init(_ initial: User? = nil) {
    if let user = initial {
      self.user = user
      Piny.api.token = user.token
    } else {
      let users = Piny.storage.fetch(User.self, limit: 1)

      if users.count == 1 {
        self.user = users[0]
        Piny.api.token = users[0].token
      }

      Piny.log("Fetched from store users(\(users.count)): \(users)")
    }
  }

  private func fetchUser(name: String) -> Promise<User> {
    Piny.api.get(
      User.self,
      path: "/\(name)"
    )
  }

  func signUp(name: String, pass: String, email: String) -> Promise<Void> {
    capture {
      Piny.api.post(
        API.Message.self,
        path: "/signup",
        data: [ "user": name, "pass": pass, "email": email ]
      )
    }.then { _ in
      self.login(
        name: name,
        pass: pass
      )
    }
  }

  func login(name: String, pass: String) -> Promise<Void> {
    var device: Device? = nil

    if let id = UIDevice.current.identifierForVendor {
      let description = """
      \(UIDevice.current.model) (\(UIDevice.current.systemName) \(UIDevice.current.systemVersion))
      """

      device = Device(id: id, description: description)
    }

    return capture {
      Piny.api.post(
        Authorisation.self,
        path: "/login",
        data: Authorisation.Payload(
          user: name,
          pass: pass,
          device: device
        )
      )
      .get { auth in
        Piny.log("Token: \(auth.token)")

        Piny.api.token = auth.token
      }
      .then { auth in
        self.fetchUser(name: name).map { user in (auth, user) }
      }.done { auth, user in
        Piny.log("User: \(user)")

        self.user = user
        self.user?.token = auth.token

        Piny.storage.remove(User.self)
        Piny.storage.save(self.user!)
      }
    }
  }

  func logout() -> Promise<Void> {
    capture {
      Piny.api.get(
        API.Message.self,
        path: "/logout"
      )
    }.done { _ in
      self.user = nil

      Piny.api.token = nil
      Piny.storage.remove(User.self)
      Piny.storage.remove(Pin.self)
    }
  }
}
