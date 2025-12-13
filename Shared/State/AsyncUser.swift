//
//  UserData.swift
//  piny
//
//  Created by John Grishin on 14/07/2020.
//  Copyright © 2020 John Grishin. All rights reserved.
//

import SwiftData
import SwiftUI

struct AsyncUserResult {
  let fetchUser = AsyncResult<UserDTO>()
  let signUp = AsyncResult<Authorization>()
  let login = AsyncResult<Authorization>()
  let refreshSession = AsyncResult<Authorization>()
  let logout = AsyncResult<PinyMessageResponse>()
}

@Observable
class AsyncUser: Async {
  let result = AsyncUserResult()

  @MainActor
  init(
    initialUser: User? = nil,
    initialSession: Session? = nil,
    modelContext: ModelContext? = nil
  ) {
    super.init(modelContext: modelContext)

    if let initialUser = initialUser { self.modelContext.insert(initialUser) }
    if let initialSession = initialSession {
      self.modelContext.insert(initialSession)
    }

    guard
      let session = (try? self.modelContext.fetch(FetchDescriptor<Session>()))?
        .last
    else {
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
    try await result.fetchUser.capture {
      try await Piny.api.get(
        UserDTO.self,
        path: "/\(name)"
      )
    }
  }

  @MainActor
  @discardableResult
  func signUp(name: String, pass: String, email: String) async throws -> Authorization {
    try await result.signUp.capture {
      try await Piny.api.post(
        PinyMessageResponse.self,
        path: "/signup",
        json: ["user": name, "pass": pass, "email": email]
      )

      return try await self.login(name: name, pass: pass)
    }
  }

  @MainActor
  @discardableResult
  func login(name: String, pass: String) async throws -> Authorization {
    let device = Device(
      id: UIDevice.current.identifierForVendor!,
      description: """
          \(UIDevice.current.model) (\(UIDevice.current.systemName) \(UIDevice.current.systemVersion))
        """
    )

    return try await result.login.capture {
      let auth = try await Piny.api.post(
        Authorization.self,
        path: "/login",
        json: Authorization.Payload(
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

      return auth
    }
  }

  @MainActor
  @discardableResult
  func refreshSession() async throws -> Authorization {
    try await result.refreshSession.capture {
      let auth = try await Piny.api.post(
        Authorization.self,
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

      return auth
    }
  }

  @MainActor
  @discardableResult
  func logout() async throws -> PinyMessageResponse {
    try await result.logout.capture {
      let result = try await Piny.api.post(
        PinyMessageResponse.self,
        path: "/logout",
        json: Optional<Data>.none
      )

      Piny.api.token = nil
      self.removeData()
      return result
    }
  }

  func removeData() {
    do {
      try self.modelContext.transaction {
        try self.modelContext.delete(model: User.self, includeSubclasses: true)
        try self.modelContext.delete(
          model: Session.self,
          includeSubclasses: true
        )
        try self.modelContext.delete(model: Pin.self, includeSubclasses: true)
        try self.modelContext.delete(
          model: PinLink.self,
          includeSubclasses: true
        )
        try self.modelContext.delete(
          model: PinTag.self,
          includeSubclasses: true
        )
      }
    } catch {
      Piny.log("Failed to remove data: \(error)", .error)
    }
  }
}
