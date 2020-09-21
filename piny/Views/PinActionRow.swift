//
//  PinAction.swift
//  piny
//
//  Created by John Grishin on 03/08/2020.
//  Copyright © 2020 John Grishin. All rights reserved.
//

import SwiftUI

private enum Action {
  case edit
  case view
  case none
}

struct PinActionRow: View {
  @EnvironmentObject var pinsState: PinsState
  @State private var selected: Action = .none
  @State var pin: Pin

  var onDelete: (() -> Void)? = nil

  private func toggle(_ action: Action) {
    self.selected = action
  }

  var body: some View {
    Button(action: { toggle(.view) }) {
      PinRow(pin: pin)
        .contextMenu {
          Button(action: { toggle(.edit) }) {
            Text("Edit")
          }
          Button(action: { onDelete?() }) {
            Text("Delete")
          }
        }
    }
    .sheet(isPresented: Binding(get: { selected != .none }, set: { _ in selected = .none })) {
      switch selected {
        case .view:
          WebView(url: pin.link.url)
            .edgesIgnoringSafeArea(.all)
        case .edit:
          PinEdit(pin: $pin.transaction(), onClose: {
            toggle(.none)
          })
          .environmentObject(pinsState)
        case .none:
          EmptyView()
      }
    }
  }
}

struct PinAction_Previews: PreviewProvider {
  static var previews: some View {
    PinActionRow(pin: PreviewContent.pins[0])
      .environmentObject(PinsState(PreviewContent.pins))
  }
}
