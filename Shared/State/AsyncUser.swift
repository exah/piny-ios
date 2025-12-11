//
//  UserData.swift
//  piny
//
//  Created by John Grishin on 14/07/2020.
//  Copyright © 2020 John Grishin. All rights reserved.
//

import SwiftData
import SwiftUI

@Observable
class AsyncUser: Async {
  @MainActor
  init(initialUser: User? = nil, initialSession: Session? = nil, modelContext: ModelContext? = nil)
  {
    super.init(modelContext: modelContext)

    if let initialUser = initialUser { self.modelContext.insert(initialUser) }
    if let initialSession = initialSession { self.modelContext.insert(initialSession) }

    guard let session = (try? self.modelContext.fetch(FetchDescriptor<Session>()))?.last else {
      Piny.api.token = nil
      return
    }

    Piny.api.token = session.token
    Task {
      do {
        try await refreshSession()
      } catch {
        Piny.log("Session refresh failed: \(error)", .error)
        self.removeData()
      }
    }
  }

  @MainActor
  private func fetchUser(name: String) async throws -> UserDTO {
    try await Piny.api.get(
      UserDTO.self,
      path: "/\(name)"
    )
  }

  @MainActor
  func signUp(name: String, pass: String, email: String) async throws {
    try await capture {
      try await Piny.api.post(
        PinyMessageResponse.self,
        path: "/signup",
        json: ["user": name, "pass": pass, "email": email]
      )

      try await self.login(name: name, pass: pass)
    }
  }

  @MainActor
  func login(name: String, pass: String) async throws {
    let device = Device(
      id: UIDevice.current.identifierForVendor!,
      description: """
        \(UIDevice.current.model) (\(UIDevice.current.systemName) \(UIDevice.current.systemVersion))
      """
    )

    try await capture {
      let auth = try await Piny.api.post(
        Authorisation.self,
        path: "/login",
        json: Authorisation.Payload(
          user: name,
          pass: pass,
          device: device
        )
      )

      Piny.log("Token: \(auth.token)")
      Piny.api.token = auth.token

      let user = try await self.fetchUser(name: name)

      Piny.log("User: \(user)")
      Piny.log("Session: \(auth)")

      do {
        try self.modelContext.transaction {
          try self.modelContext.delete(model: User.self)
          try self.modelContext.delete(model: Session.self)
          self.modelContext.insert(User(from: user))
          self.modelContext.insert(Session(from: auth))
        }
      } catch {
        Piny.log("Failed to update user/session: \(error)", .error)
        throw error
      }
    }
  }

  @MainActor
  func refreshSession() async throws {
    try await capture {
      let auth = try await Piny.api.post(
        Authorisation.self,
        path: "/refresh-session",
        json: Optional<Data>.none
      )

      Piny.log("Token: \(auth.token)")
      Piny.api.token = auth.token

      do {
        try self.modelContext.transaction {
          try self.modelContext.delete(model: Session.self)
          self.modelContext.insert(Session(from: auth))
        }
      } catch {
        Piny.log("Failed to update session: \(error)", .error)
        throw error
      }
    }
  }

  @MainActor
  func logout() async throws {
    try await capture {
      try await Piny.api.post(
        PinyMessageResponse.self,
        path: "/logout",
        json: Optional<Data>.none
      )

      Piny.api.token = nil
      self.removeData()
    }
  }

  func removeData() {
    do {
      try self.modelContext.transaction {
        try self.modelContext.delete(model: User.self, includeSubclasses: true)
        try self.modelContext.delete(model: Session.self, includeSubclasses: true)
        try self.modelContext.delete(model: Pin.self, includeSubclasses: true)
        try self.modelContext.delete(model: PinLink.self, includeSubclasses: true)
        try self.modelContext.delete(model: PinTag.self, includeSubclasses: true)
      }
    } catch {
      Piny.log("Failed to remove data: \(error)", .error)
    }
  }
}
