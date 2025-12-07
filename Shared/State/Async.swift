//
//  AsyncState.swift
//  piny
//
//  Created by John Grishin on 31/07/2020.
//  Copyright © 2020 John Grishin. All rights reserved.
//

import Foundation
import SwiftData

@Observable
class Async {
  @ObservationIgnored
  let modelContext: ModelContext
  var isLoading: Bool = false

  @MainActor
  init(modelContext: ModelContext? = nil) {
    let ctx = modelContext ?? Piny.storage.container.mainContext
    self.modelContext = ctx
  }

  @MainActor
  @discardableResult
  func capture<T>(_ body: () async throws -> T) async throws -> T {
    isLoading = true
    return try await withTaskCancellationHandler {
      defer { isLoading = false }
      return try await body()
    } onCancel: {
      isLoading = false
    }
  }
}
