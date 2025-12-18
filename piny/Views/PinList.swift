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
  var onEdit: ((_ pin: Pin) -> Void)? = nil
  var onRefresh: (() async -> Void)? = nil
  var onDelete: ((_ pins: [Pin]) -> Void)? = nil

  var body: some View {
    List {
      ForEach(pins, id: \.persistentModelID) { pin in
        PinActionRow(
          pin: pin,
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

#Preview {
  PinList(pins: PreviewContent.pins)
}
