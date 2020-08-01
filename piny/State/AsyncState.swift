//
//  AsyncState.swift
//  piny
//
//  Created by John Grishin on 31/07/2020.
//  Copyright © 2020 John Grishin. All rights reserved.
//

import Foundation
import PromiseKit

protocol AsyncState: ObservableObject {
  var isLoading: Bool { get set }

  func capture<T>(_ body: () -> Promise<T>) -> Promise<T>
}

extension AsyncState {
  func capture<T>(_ body: () -> Promise<T>) -> Promise<T> {
    self.isLoading = true

    return body().ensure {
      self.isLoading = false
    }
  }
}
