//
//  UserData.swift
//  piny
//
//  Created by John Grishin on 14/07/2020.
//  Copyright © 2020 John Grishin. All rights reserved.
//

import PromiseKit
import SwiftUI
import SwiftData

@Observable
class AsyncUser: Async {
  @MainActor
  init(_ initial: User? = nil, modelContext: ModelContext? = nil) {
    super.init(modelContext: modelContext)

    if let initialUser = initial { self.modelContext.insert(initialUser) }
    if let existingUser = (try? self.modelContext.fetch(FetchDescriptor<User>()))?.first {
      Piny.api.token = existingUser.token
      self.refreshSession().catch { _ in
        self.removeData()
      }
    } else {
      Piny.api.token = nil
    }
  }

  private func fetchUser(name: String) -> Promise<UserDTO> {
    Piny.api.get(
      UserDTO.self,
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

        let entity = User(from: user)
        entity.token = auth.token

        self.modelContext.insert(entity)
      }
    }
  }

  func refreshSession() -> Promise<Void> {
    return capture {
      Piny.api.post(
        Authorisation.self,
        path: "/refresh-session",
        data: Optional<Data>.none
      )
      .done { auth in
        Piny.log("Token: \(auth.token)")

        let user = try self.modelContext.fetch(FetchDescriptor<User>()).first

        Piny.api.token = auth.token
        user?.token = auth.token
      }
    }
  }

  func logout() -> Promise<Void> {
    capture {
      Piny.api.post(
        API.Message.self,
        path: "/logout",
        data: Optional<Data>.none
      )
    }.done { _ in
      Piny.api.token = nil

      self.removeData()
    }
  }

  func removeData() {
    try? self.modelContext.delete(model: User.self)
    try? self.modelContext.delete(model: Pin.self)
    try? self.modelContext.delete(model: PinTag.self)
  }
}

