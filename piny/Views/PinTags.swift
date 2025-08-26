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

fileprivate let CREATE_TAG: PinTag = PinTag(
  id: UUID(),
  name: "create"
)

struct PinTags: View {
  @EnvironmentObject var tagsState: TagsState
  @Binding var tags: [PinTag]

  var body: some View {
    WrappingHStack(
      [CREATE_TAG] + tags,
      id: \.self,
      alignment: .leading,
      spacing: .constant(8),
      lineSpacing: 8
    ) { tag in
      if tag == CREATE_TAG {
        TagSelect(
          tags: $tags,
          options: tagsState.tags
        )
      } else {
        Menu {
          Button("Delete: \(tag.name)") {
            tags.removeAll(where: { $0 == tag })
          }
        } label:  {
          Tag(value: tag)
        }
      }
    }
  }
}


#Preview {
  PinTags(tags: Binding.constant(PreviewContent.pins[0].tags))
    .environmentObject(TagsState(PreviewContent.pins[0].tags))
}
