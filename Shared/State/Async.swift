//
//  AsyncState.swift
//  piny
//
//  Created by John Grishin on 31/07/2020.
//  Copyright © 2020 John Grishin. All rights reserved.
//

import Foundation
import SwiftData
import PromiseKit

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

  func capture<T>(_ body: () -> Promise<T>) -> Promise<T> {
    self.isLoading = true

    return body().ensure {
      self.isLoading = false
    }
  }
}
