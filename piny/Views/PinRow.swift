//
//  PinRow.swift
//  piny
//
//  Created by John Grishin on 15/07/2020.
//  Copyright © 2020 John Grishin. All rights reserved.
//

import SwiftUI

struct PinRow: View {
  var pin: Pin
  
  var body: some View {
    HStack {
      VStack(alignment: .leading, spacing: 8) {
        if (pin.title != nil) {
          Text(pin.title!)
        }
        if (pin.description != nil) {
          Text(pin.description!)
        }
        Text("\(pin.link.url)")
        PinRowTags(tags: pin.tags)
      }
      
      Spacer()
    }
  }
}

struct PinRow_Previews: PreviewProvider {
  static var previews: some View {
    PinRow(pin: PREVIEW_PINS[2])
      .previewLayout(.fixed(width: 300, height: 120))
  }
}
