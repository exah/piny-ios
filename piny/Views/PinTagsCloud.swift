//
//  PinRowTags.swift
//  piny
//
//  Created by John Grishin on 15/07/2020.
//  Copyright © 2020 John Grishin. All rights reserved.
//

import SwiftData
import SwiftUI

struct PinTagsCloud: View {
  @Binding
  var tags: [PinTag]

  var body: some View {
    Flow(spacing: 8) {
      TagSelect(
        tags: tags,
        onChange: { newTags in
          self.tags.removeAll()
          self.tags.append(contentsOf: newTags)
        }
      )
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
  }
}

#Preview {
  let tags = PreviewContent.pins[0].tags
  let options = PreviewContent.tags

  PinTagsCloud(tags: .constant(tags))
}
