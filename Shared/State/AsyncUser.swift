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
  init(initialUser: User? = nil, initialSession: Session? = nil, modelContext: ModelContext? = nil) {
    super.init(modelContext: modelContext)

    if let initialUser = initialUser { self.modelContext.insert(initialUser) }
    if let initialSession = initialSession { self.modelContext.insert(initialSession) }
    let sessions = try? self.modelContext.fetch(FetchDescriptor<Session>())

    guard let session = sessions?.last else {
      Piny.api.token = nil
      return
    }

    Piny.api.token = session.token
    refreshSession().catch { _ in
      self.removeData()
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
    var device = Device(
      id: UIDevice.current.identifierForVendor!,
      description: """
        \(UIDevice.current.model) (\(UIDevice.current.systemName) \(UIDevice.current.systemVersion))
      """
    )

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
      }.done { session, user in
        Piny.log("User: \(user)")
        Piny.log("Session: \(session)")

        try? self.modelContext.delete(model: User.self)
        try? self.modelContext.delete(model: Session.self)
        self.modelContext.insert(User(from: user))
        self.modelContext.insert(Session(from: session))
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
        Piny.api.token = auth.token

        try? self.modelContext.delete(model: Session.self)
        self.modelContext.insert(Session(from: auth))
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
    try? self.modelContext.delete(model: Session.self)
    try? self.modelContext.delete(model: Pin.self)
    try? self.modelContext.delete(model: PinTag.self)
  }
}

