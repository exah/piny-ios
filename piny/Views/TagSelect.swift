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
  @State private var selectedIds: Set<UUID> = []
  @State private var isPresented: Bool = false

  private func commitChanges() {
    let currentIds = Set(tags.map { $0.id })
    let removedIds = currentIds.subtracting(selectedIds)
    let addedIds = selectedIds.subtracting(currentIds)
    var updatedTags = tags.filter { !removedIds.contains($0.id) }
    let newTags = options.filter { addedIds.contains($0.id) }

    updatedTags.append(contentsOf: newTags)
    tags = updatedTags
  }

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

            ForEach(options, id: \.persistentModelID) { option in
              Button(action: {
                if selectedIds.contains(option.id) {
                  selectedIds.remove(option.id)
                } else {
                  selectedIds.insert(option.id)
                }
              }) {
                Label(
                  option.name,
                  systemImage: selectedIds.contains(option.id)
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
      .onChange(of: isPresented) { oldValue, newValue in
        if newValue {
          selectedIds = Set(tags.map { $0.id })
        } else {
          commitChanges()
        }
      }
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
