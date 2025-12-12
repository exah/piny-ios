//
//  SwiftUIView.swift
//  piny
//
//  Created by J. Grishin on 26/08/2025.
//  Copyright © 2025 John Grishin. All rights reserved.
//

import SwiftUI

struct CreateTagForm: View {
  @State
  var value: String = ""
  @Binding
  var tags: [PinTag]

  var options: [PinTag]
  let onClose: () -> Void

  var body: some View {
    Group {
      TextField("Enter name", text: $value)
        .textInputAutocapitalization(.never)
      Button(action: {
        if let existing = options.first(where: {
          $0.name == value
        }) {
          tags.append(existing)
        } else {
          tags.append(PinTag(id: UUID(), name: value))
        }

        onClose()
        value = ""
      }) {
        Text("Add")
      }
      Button(role: .cancel) {}
    }
  }
}

#Preview {
  CreateTagForm(tags: Binding.constant([]), options: [], onClose: {})
}
