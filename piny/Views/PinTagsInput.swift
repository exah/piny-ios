//
//  PinRowTags.swift
//  piny
//
//  Created by John Grishin on 15/07/2020.
//  Copyright © 2020 John Grishin. All rights reserved.
//

import SwiftData
import SwiftUI

struct PinTagsInput: View {
  @Binding
  var tags: [PinTag]

  var body: some View {
    HStack(spacing: 8) {
      Flow(spacing: 8) {
        ForEach(tags, id: \.id) { tag in
          Menu {
            Button("Delete: \(tag.name)") {
              tags.removeAll(where: { $0.id == tag.id })
            }
          } label: {
            Tag(value: tag)
          }
        }
      }
      .frame(maxWidth: .infinity, alignment: .leading)
      TagSelect(tags: $tags)
    }
    .frame(maxWidth: .infinity)
    .textFieldVariant(.primary, size: .tags)
  }
}

#Preview {
  let tags = PreviewContent.pins[0].tags

  PinTagsInput(tags: .constant(tags))
}
