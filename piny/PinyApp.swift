//
//  PinyApp.swift
//  piny
//
//  Created by J. Grishin on 26/08/2025.
//  Copyright © 2025 John Grishin. All rights reserved.
//

import Sentry
import SwiftData
import SwiftUI

@main
struct PinyApp: App {
  init() {
    Piny.Sentry()
  }

  var body: some Scene {
    WindowGroup {
      Root()
    }
    .modelContainer(Piny.storage.container)
    .environment(SessionState())
    .environment(PinState())
    .environment(TagState())
  }
}
