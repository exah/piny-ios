//
//  PinRow.swift
//  piny
//
//  Created by John Grishin on 15/07/2020.
//  Copyright © 2020 John Grishin. All rights reserved.
//

import SwiftUI
import PromiseKit

struct PinRow: View {
  @Environment(AsyncPins.self) var asyncPins
  @Bindable var pin: Pin
  var tags: [PinTag]

  func update(tags: [PinTag]) {
    firstly {
      asyncPins.edit(
        pin,
        tags: tags.map { $0.name }
      )
    }.catch { error in
      Piny.log(error, .error)
      asyncPins.get(pin).cauterize()
    }
  }

  var body: some View {
    VStack(alignment: .leading, spacing: 16) {
      VStack(alignment: .leading, spacing: 8) {
        if (pin.title != nil) {
          Text(pin.title!)
            .fontWeight(.semibold)
            .lineLimit(1)
        }
        if (pin.desc != nil) {
          Text(pin.desc!)
            .lineLimit(2)
        }
        Text("\(pin.link.url)")
          .lineLimit(1)
      }
      PinTags(tags: Binding(
        get: { pin.orderedTags },
        set: { newTags in
          pin.tags = newTags
          pin.tagOrder = newTags.map { $0.id }
        }
      ), options: tags)
        .onChange(of: pin.tags) {
          update(tags: pin.orderedTags)
        }
    }
    .padding(.vertical, 2)
  }
}

#Preview {
  PinRow(pin: PreviewContent.pins[2], tags: PreviewContent.tags)
    .environment(AsyncPins(PreviewContent.pins))
}
