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
  @State
  var tagActor = TagActor(modelContainer: .shared)

  @Binding
  var tags: [TagModel]

  @State
  var search = ""

  @State
  private var isPresented: Bool = false

  @Query(TagActor.Descriptors.all())
  var options: [TagModel]

  private var filteredOptions: [TagModel] {
    guard !search.isEmpty else {
      return options.sorted(using: TagActor.Descriptors.sort(.count))
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
      guard let tag = try? await tagActor.insert(search) else {
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
          Input(
            "Search..",
            type: .text,
            value: $search,
            leading: { Image(systemName: "magnifyingglass") }
          )
          .autocapitalization(.none)
          .autocorrectionDisabled()
        }
        .padding(8)
        Divider()
        ScrollView {
          VStack(alignment: .leading, spacing: 0) {
            if filteredOptions.isEmpty && !search.isEmpty {
              Button(action: handleCreateTask) {
                Label("New tag \"\(search)\"", systemImage: "plus")
                  .frame(maxWidth: .infinity, alignment: .leading)
                  .padding(.horizontal, 16)
                  .padding(.vertical, 12)
                  .clipShape(.rect(corners: .concentric))
              }
              .buttonStyle(.plain)
            } else {
              ForEach(filteredOptions, id: \.id) { option in
                TagOption(
                  tag: option,
                  selected: tags.contains(option),
                  onToggle: {
                    if let index = tags.firstIndex(of: option) {
                      tags.remove(at: index)
                    } else {
                      tags.append(option)
                    }
                  }
                )
              }
            }
          }
          .frame(maxWidth: .infinity, alignment: .leading)
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
      .contentShape(
        ConcentricRectangle(
          corners: .concentric(minimum: 20),
          isUniform: true
        )
      )
      .frame(minWidth: 250, maxHeight: 450)
      .presentationCompactAdaptation(.popover)
    }
  }
}

#Preview {
  TagSelect(
    tags: .constant([])
  )
  .environment(TagState(PreviewContent.tags))
}
