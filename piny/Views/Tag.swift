//
//  Tag.swift
//  piny
//
//  Created by J. Grishin on 22/08/2025.
//  Copyright © 2025 John Grishin. All rights reserved.
//

import SwiftUI

struct Tag: View {
  var value: PinTag

  var body: some View {
    ZStack {
      Text(value.name)
        .lineLimit(1)
        .fixedSize()
        .buttonSize(.tag)
        .foregroundStyle(.grey80)
        .background(Color.grey20)
        .cornerRadius(8)
    }
  }
}

#Preview {
  HStack(spacing: 16) {
    Tag(value: PinTag(id: UUID(), name: "one"))
    Tag(value: PinTag(id: UUID(), name: "two"))
    Tag(value: PinTag(id: UUID(), name: "long-text-tag"))
  }
}
