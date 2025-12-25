//
//  Tag.swift
//  piny
//
//  Created by J. Grishin on 22/08/2025.
//  Copyright © 2025 John Grishin. All rights reserved.
//

import SwiftUI

struct Tag: View {
  var value: TagModel

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
    Tag(value: TagModel(id: UUID(), name: "one"))
    Tag(value: TagModel(id: UUID(), name: "two"))
    Tag(value: TagModel(id: UUID(), name: "long-text-tag"))
  }
}
