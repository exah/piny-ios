//
//  PinRowTags.swift
//  piny
//
//  Created by John Grishin on 15/07/2020.
//  Copyright © 2020 John Grishin. All rights reserved.
//

import SwiftUI
import WrappingHStack
import PromiseKit
import SwiftData

fileprivate let CREATE_TAG: PinTag = PinTag(
  id: UUID(),
  name: "create"
)

struct PinTags: View {
  @Binding var tags: [PinTag]

  var displayList: [PinTag] { [CREATE_TAG] + tags }
  var options: [PinTag]

  var body: some View {
    WrappingHStack(
      displayList,
      id: \.self,
      alignment: .leading,
      spacing: .constant(8),
      lineSpacing: 8
    ) { tag in
      if tag == CREATE_TAG {
        TagSelect(options: options, tags: $tags)
      } else {
        Menu {
          Button("Delete: \(tag.name)") {
            tags.removeAll(where: { $0.id == tag.id })
          }
        } label:  {
          Tag(value: tag)
        }
      }
    }
  }
}


#Preview {
  let tags = PreviewContent.pins[0].tags
  let options = PreviewContent.tags

  PinTags(tags: Binding.constant(tags), options: options)
}
