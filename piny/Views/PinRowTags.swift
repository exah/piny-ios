//
//  PinRowTags.swift
//  piny
//
//  Created by John Grishin on 15/07/2020.
//  Copyright © 2020 John Grishin. All rights reserved.
//

import SwiftUI

struct PinRowTags: View {
  var tags: [PinTag]
  
  var body: some View {
    HStack(spacing: 4) {
      ForEach(tags) { tag in
        Text(tag.name).font(.caption)
      }
    }
  }
}


struct PinRowTags_Previews: PreviewProvider {
  static var previews: some View {
    PinRowTags(tags: PreviewContent.pins[0].tags)
  }
}
