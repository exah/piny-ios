//
//  Storage.swift
//  piny
//
//  Created by John Grishin on 21/07/2020.
//  Copyright © 2020 John Grishin. All rights reserved.
//

import CoreData
import SwiftData

final class Storage {
  let container: ModelContainer

  init(_ name: String, schema: Schema) {
    let configuration = ModelConfiguration(name, schema: schema)

    do {
      container = try ModelContainer(for: schema, configurations: [configuration])
    } catch let error {
      fatalError(error.localizedDescription)
    }
  }
}
