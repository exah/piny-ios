//
//  SwiftUIView.swift
//  piny
//
//  Created by J. Grishin on 26/08/2025.
//  Copyright © 2025 John Grishin. All rights reserved.
//

import SwiftData
import SwiftUI

struct CreateTagForm: View {
  @State
  var value: String = ""

  var options: [PinTag]
  var modelContext: ModelContext
  let onCreate: (_ tag: PinTag) -> Void

  var body: some View {
    Group {
      TextField("Enter name", text: $value)
        .textInputAutocapitalization(.never)
      Button(action: {
        let tag: PinTag
        if let existing = options.first(where: { $0.name == value }) {
          tag = existing
        } else {
          tag = PinTag(id: UUID(), name: value)
          modelContext.insert(tag)
        }

        onCreate(tag)
        value = ""
      }) {
        Text("Add")
      }
      Button(role: .cancel) {}
    }
  }
}

#Preview {
  CreateTagForm(options: [], modelContext: Piny.storage.container.mainContext, onCreate: { _ in })
}
