//
//  PinList.swift
//  piny
//
//  Created by John Grishin on 13/07/2020.
//  Copyright © 2020 John Grishin. All rights reserved.
//

import SwiftData
import SwiftUI

struct PinList: View {
  var pins: [Pin]
  var tags: [PinTag]
  var onEdit: ((_ pin: Pin) -> Void)? = nil
  var onRefresh: (() async -> Void)? = nil
  var onDelete: ((_ pins: [Pin]) -> Void)? = nil

  var body: some View {
    List {
      ForEach(pins, id: \.persistentModelID) { pin in
        PinActionRow(
          pin: pin,
          tags: tags,
          onDelete: {
            self.onDelete?([pin])
          }
        )
      }
      .onDelete { offsets in
        if let first = offsets.first, let last = offsets.last {
          self.onDelete?(Array(self.pins[first...last]))
        }
      }
    }
    .refreshable {
      await onRefresh?()
    }
  }
}

struct PinList_Previews: PreviewProvider {
  static var previews: some View {
    PinList(pins: PreviewContent.pins, tags: PreviewContent.tags)
  }
}
