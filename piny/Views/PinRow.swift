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
  @EnvironmentObject var pinsState: PinsState

  @Binding var pin: Pin
  @State var task: Task<Void, Never>?

  func update(tags: [PinTag]) {
    firstly {
      pinsState.edit(
        pin,
        tags: tags.map { $0.name }
      )
    }.catch { error in
      Piny.log(error, .error)
    }
  }

  var body: some View {
    HStack {
      VStack(alignment: .leading, spacing: 16) {
        VStack(alignment: .leading, spacing: 8) {
          if (pin.title != nil) {
            Text(pin.title!)
              .fontWeight(.semibold)
              .lineLimit(1)
          }
          if (pin.description != nil) {
            Text(pin.description!)
              .lineLimit(2)
          }
          Text("\(pin.link.url)")
            .lineLimit(1)
        }
        PinTags(tags: $pin.tags)
          .onChange(of: pin.tags) {
            task?.cancel()
            task = Task { @MainActor in
              try? await Task.sleep(nanoseconds: 2 * 1000 * 1000_000)
              Piny.log("saved")
              update(tags: pin.tags)
            }
          }
      }
      
      Spacer()
    }
  }
}

struct PinRow_Previews: PreviewProvider {
  static var previews: some View {
    PinRow(pin: Binding.constant(PreviewContent.pins[2]))
      .previewLayout(.fixed(width: 300, height: 120))
      .environmentObject(TagsState(PreviewContent.pins[0].tags))
  }
}
