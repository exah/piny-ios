//
//  TagSelect.swift
//  piny
//
//  Created by J. Grishin on 23/08/2025.
//  Copyright © 2025 John Grishin. All rights reserved.
//

import SwiftUI
import Combine

struct TagSelect: View {
  @Binding var tags: [PinTag]
  @State var creating: Bool = false
  @State var value: String = ""

  let options: [PinTag]

  var body: some View {
    Menu {
      Button(action: {
        creating.toggle()
        Piny.log("Creating \(creating)")
      }) {
        Label("New tag", systemImage: "plus")
      }
      Section("Tags") {
        ForEach(options, id: \.self) { option in
          Button(action: {
            if let index = tags.lastIndex(of: option) {
              tags.remove(at: index)
            } else {
              tags.append(option)
            }
          }) {
            Label(
              option.name,
              systemImage: tags.contains(option)
              ? "checkmark.circle.fill"
              : "circle"
            )
          }
        }
      }
    } label: {
      Button(action: {}) {}
        .variant(
          .secondary,
          size: .tag,
          icon: Image(systemName: "plus"),
          hug: true
        )
    }
    .menuOrder(.fixed)
    .menuActionDismissBehavior(.disabled)
    .alert("New tag", isPresented: $creating) {
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

        creating.toggle()
        value = ""
      }) {
        Text("Add")
      }
    }
  }
}

#Preview {
  TagSelect(tags: Binding.constant([]), options: [])
}
