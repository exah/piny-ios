//
//  TagOption.swift
//  piny
//
//  Created by J. Grishin on 28/12/2025.
//  Copyright © 2025 John Grishin. All rights reserved.
//

import Combine
import SwiftData
import SwiftUI

struct TagOption: View {
  let tag: TagModel
  let selected: Bool
  let onToggle: () -> Void

  var body: some View {
    Button(action: onToggle) {
      HStack {
        Image(
          systemName: selected
            ? "tag.fill"
            : "tag"
        )
        Text(tag.name)
        Spacer()
        if selected {
          Image(systemName: "checkmark.circle.fill")
            .frame(minWidth: 24, alignment: .center)
        } else {
          Text("\(tag.pins.count)")
            .variant(.tertiary)
            .padding(4)
            .frame(minWidth: 24)
            .background(
              Color.piny.background,
              in: .rect(
                corners: .concentric(minimum: 20),
                isUniform: true
              )
            )
        }
      }
      .frame(maxWidth: .infinity, alignment: .leading)
      .padding(.horizontal, 16)
      .padding(.vertical, 12)
      .contentShape(
        ConcentricRectangle(
          corners: .concentric(minimum: 20),
          isUniform: true
        )
      )
    }
    .buttonStyle(.plain)
  }

}

#Preview {
  TagOption(
    tag: PreviewContent.tags[0],
    selected: false,
    onToggle: {}
  )
}
