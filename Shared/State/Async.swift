//
//  AsyncState.swift
//  piny
//
//  Created by John Grishin on 31/07/2020.
//  Copyright © 2020 John Grishin. All rights reserved.
//

import Foundation
import SwiftData

enum AsyncStatus<T> {
  case idle
  case loading
  case success(_ data: T)
  case error(_ error: Error)
}

@Observable
class AsyncResult<Data> {
  var status: AsyncStatus<Data> = .idle

  var isLoading: Bool {
    switch status {
      case .loading: return true
      default: return false
    }
  }

  var isSuccess: Bool {
    switch status {
      case .success: return true
      default: return false
    }
  }

  var isError: Bool {
    switch status {
      case .error: return true
      default: return false
    }
  }

  var data: Data? {
    switch status {
      case .success(let data): return data
      default: return nil
    }
  }

  @MainActor
  @discardableResult
  func capture(body: () async throws -> Data) async throws -> Data {
    status = .loading
    return try await withTaskCancellationHandler {
      do {
        let data = try await body()
        status = .success(data)
        return data
      } catch {
        status = .error(error)
        throw error
      }
    } onCancel: {
      status = .idle
    }
  }
}

class Async {
  let modelContext: ModelContext

  @MainActor
  init(modelContext: ModelContext? = nil) {
    let ctx = modelContext ?? Piny.storage.container.mainContext
    self.modelContext = ctx
  }
}
