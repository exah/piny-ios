//
//  PinyApp.swift
//  piny
//
//  Created by J. Grishin on 26/08/2025.
//  Copyright © 2025 John Grishin. All rights reserved.
//

import SwiftData
import SwiftUI

@main
struct PinyApp: App {
  var body: some Scene {
    WindowGroup {
      Root()
    }
    .modelContainer(Piny.storage.container)
    .environment(AsyncUser(modelContext: Piny.storage.container.mainContext))
    .environment(AsyncPins(modelContext: Piny.storage.container.mainContext))
    .environment(AsyncTags())
  }
}
