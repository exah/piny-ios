//
//  PinRow.swift
//  piny
//
//  Created by John Grishin on 15/07/2020.
//  Copyright © 2020 John Grishin. All rights reserved.
//

import SwiftUI

struct PinRow: View {
  @Environment(PinsState.self)
  var pinsState

  @Bindable
  var pin: Pin

  func updateTags() async {
    do {
      try await pinsState.edit(
        pin,
        url: pin.link.url,
        title: pin.title,
        description: pin.desc,
        privacy: pin.privacy,
        tags: pin.tags.map { $0.name }
      )
    } catch {
      Piny.log("Failed to update: \(error)", .error)
    }
  }

  @State
  var task: Task<Void, Error>? = nil
  func handleTagsChange() {
    task?.cancel()
    task = Task {
      try await Task.sleep(for: .milliseconds(400))
      await updateTags()
      task = nil
    }
  }

  private var tagsSet: Set<String> {
    Set(pin.tags.map { $0.name })
  }

  var body: some View {
    VStack(alignment: .leading, spacing: 16) {
      VStack(alignment: .leading, spacing: 8) {
        if !pin.title.isEmpty {
          Text(pin.title)
            .fontWeight(.semibold)
            .lineLimit(1)
        }
        if !pin.desc.isEmpty {
          Text(pin.desc)
            .lineLimit(2)
        }
        Text("\(pin.link.url)")
          .lineLimit(1)
      }
      PinTagsCloud(tags: $pin.tags)
        .onChange(of: tagsSet) { old, new in
          handleTagsChange()
        }
    }
    .padding(.vertical, 2)
  }
}

#Preview {
  PinRow(pin: PreviewContent.pins[2])
    .environment(PinsState(PreviewContent.pins))
}
