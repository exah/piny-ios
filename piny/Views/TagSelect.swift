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
  var tagsActor = TagsActor(modelContainer: .shared)

  @Binding
  var tags: [PinTag]

  @State
  var search = ""

  @State
  private var isPresented: Bool = false

  @Query(sort: \PinTag.name, order: .forward)
  var options: [PinTag]

  private var filteredOptions: [PinTag] {
    guard !search.isEmpty else {
      return options
    }

    let searchLower = search.lowercased()
    return options.filter { tag in
      let tagName = tag.name.lowercased()
      if tagName.contains(searchLower) {
        return true
      }

      var searchIndex = searchLower.startIndex
      for char in tagName {
        if searchIndex < searchLower.endIndex && char == searchLower[searchIndex] {
          searchIndex = searchLower.index(after: searchIndex)
        }
      }
      return searchIndex == searchLower.endIndex
    }
  }

  func handleCreateTask() {
    Task {
      guard let tag = try? await tagsActor.create(search) else {
        return
      }

      tags.append(tag)
      search = ""
    }
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
      VStack(alignment: .leading, spacing: 0) {
        VStack {
          Input("Search..", type: .text, value: $search)
            .autocapitalization(.none)
            .autocorrectionDisabled()
        }
        .padding(8)

        Divider()

        ScrollView {
          VStack(alignment: .leading, spacing: 0) {
            if filteredOptions.isEmpty && !search.isEmpty {
              Button(action: handleCreateTask) {
                Label("Create \"\(search)\"", systemImage: "plus.circle.fill")
                  .padding(.horizontal, 16)
                  .padding(.vertical, 12)
              }
              .buttonStyle(.plain)
            } else {
              ForEach(filteredOptions, id: \.id) { option in
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
          .padding(8)
        }
        .frame(
          minWidth: 0,
          maxWidth: .infinity,
          minHeight: 0,
          maxHeight: .infinity,
          alignment: .topLeading
        )
      }
      .frame(minWidth: 250, maxHeight: 450)
      .presentationCompactAdaptation(.popover)
    }
  }
}

#Preview {
  TagSelect(
    tags: .constant([])
  )
}
