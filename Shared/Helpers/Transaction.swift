//
//  Transaction.swift
//  piny
//
//  Created by John Grishin on 03/08/2020.
//  Copyright © 2020 John Grishin. All rights reserved.
//

import SwiftUI
import Combine

@propertyWrapper
@dynamicMemberLookup
struct Transaction<Value>: DynamicProperty {
  @State private var derived: Value
  @Binding private var source: Value

  fileprivate init(source: Binding<Value>) {
    self._source = source
    self._derived = State(wrappedValue: source.wrappedValue)
  }

  var wrappedValue: Value {
    get { derived }
    nonmutating set { derived = newValue }
  }

  var projectedValue: Transaction<Value> { self }

  subscript<T>(dynamicMember keyPath: WritableKeyPath<Value, T>) -> Binding<T> {
    return $derived[dynamicMember: keyPath]
  }

  var binding: Binding<Value> { $derived }

  func commit() {
    source = derived
  }

  func rollback() {
    derived = source
  }
}

extension Transaction where Value: Equatable {
  var hasChanges: Bool { return source != derived }
}

extension Binding {
  func transaction() -> Transaction<Value> { .init(source: self) }
}
