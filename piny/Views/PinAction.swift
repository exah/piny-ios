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
}

struct PinActionRow<Row>: View where Row : View {
  @State private var isOpen: Bool = false
  @State private var selected: Action = .view

  var pin: Pin
  var row: () -> Row

  init(
    pin: Pin,
    @ViewBuilder row: @escaping () -> Row
  ) {
    self.pin = pin
    self.row = row
  }

  private func toggle(_ action: Action) {
    self.isOpen.toggle()
    self.selected = action
  }

  var body: some View {
    Button(action: { self.toggle(.view) }) {
      self.row()
        .contextMenu {
          Button(action: { self.toggle(.edit) }) {
            Text("Edit")
          }
          Button(action: { log("Delete") }) {
            Text("Delete")
          }
        }
    }
    .sheet(isPresented: $isOpen) {
      if self.selected == .view {
        WebView(url: self.pin.link.url)
          .edgesIgnoringSafeArea(.all)
      } else if self.selected == .edit {
        PinEdit(pin: self.pin)
      }
    }
  }
}

struct PinAction_Previews: PreviewProvider {
  static var previews: some View {
    PinActionRow(pin: PreviewContent.pins[0]) {
      PinRow(pin: PreviewContent.pins[0])
    }
  }
}
