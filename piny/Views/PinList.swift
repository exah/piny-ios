//
//  PinList.swift
//  piny
//
//  Created by John Grishin on 13/07/2020.
//  Copyright © 2020 John Grishin. All rights reserved.
//

import SwiftUI

struct PinList: View {
  var pins: [Pin] = []
  var onEdit: ((_ pin: Pin) -> Void)? = nil
  var onDelete: ((_ pins: [Pin]) -> Void)? = nil

  var body: some View {
    List {
      ForEach(pins) { pin in
        PinActionRow(pin: pin, onDelete: {
          self.onDelete?([pin])
        })
          .padding(.vertical, 2)
      }
      .onDelete { offsets in
        if let first = offsets.first, let last = offsets.last {
          self.onDelete?(Array(self.pins[first...last]))
        }
      }
    }
  }
}

struct PinList_Previews: PreviewProvider {
  static var previews: some View {
    PinList(pins: PreviewContent.pins)
  }
}
