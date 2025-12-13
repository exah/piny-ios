//
//  TagSelect.swift
//  piny
//
//  Created by J. Grishin on 23/08/2025.
//  Copyright © 2025 John Grishin. All rights reserved.
//

import Combine
import SwiftData
import SwiftUI

struct TagSelect: View {
  @Environment(\.modelContext)
  private var modelContext

  @State
  var tags: [PinTag]

  @State
  var creating: Bool = false

  @State
  private var isPresented: Bool = false

  var options: [PinTag]
  var onChange: ([PinTag]) -> Void

  var body: some View {
    Button(action: {
      isPresented = true
    }) {}
    .variant(
      .secondary,
      size: .tag,
      icon: Image(systemName: "plus"),
      hug: true
    )
    .popover(isPresented: $isPresented) {
      ScrollView {
        VStack(alignment: .leading, spacing: 0) {
          Button(action: {
            creating.toggle()
            Piny.log("Creating \(creating)")
          }) {
            Label("New tag", systemImage: "plus")
              .frame(maxWidth: .infinity, alignment: .leading)
              .padding(.horizontal, 16)
              .padding(.vertical, 12)
          }
          .buttonStyle(.plain)

          Divider()

          ForEach(options, id: \.id) { option in
            Button(action: {
              if let index = tags.firstIndex(of: option) {
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
              .padding(.horizontal, 16)
              .padding(.vertical, 12)
            }
            .buttonStyle(.plain)
          }
        }
      }
      .frame(width: 250, height: 400)
      .presentationCompactAdaptation(.popover)
    }
    .onChange(of: isPresented) {
      if !isPresented && !creating {
        self.onChange(tags)
      }
    }
    .alert("New tag", isPresented: $creating) {
      CreateTagForm(
        options: options,
        modelContext: modelContext,
        onCreate: { newTag in
          creating.toggle()
          tags.append(newTag)

          self.onChange(tags)
        }
      )
    }
  }
}

#Preview {
  TagSelect(tags: [], options: [], onChange: { _ in })
}
