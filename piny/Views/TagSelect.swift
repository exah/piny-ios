//
//  TagSelect.swift
//  piny
//
//  Created by J. Grishin on 23/08/2025.
//  Copyright © 2025 John Grishin. All rights reserved.
//

import SwiftUI
import SwiftData
import Combine

struct TagSelect: View {
  var options: [PinTag]

  @Binding var tags: [PinTag]
  @State var creating: Bool = false
  @State var value: String = ""

  var body: some View {
    Menu {
      Button(action: {
        creating.toggle()
        Piny.log("Creating \(creating)")
      }) {
        Label("New tag", systemImage: "plus")
      }
      ForEach(options, id: \.persistentModelID) { option in
        Button(action: {
          if let index = tags.firstIndex(of: option){
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
        .tag(option)
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
      CreateTagForm(
        tags: $tags,
        options: options,
        onClose: { creating.toggle() }
      )
    }
  }
}

#Preview {
  TagSelect(options: [], tags: Binding.constant([]))
}
