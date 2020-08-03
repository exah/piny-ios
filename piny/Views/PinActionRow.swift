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

struct PinActionRow: View {
  @EnvironmentObject var pinsState: PinsState
  @State private var isOpen: Bool = false
  @State private var selected: Action? = nil
  @State var pin: Pin

  var onDelete: (() -> Void)? = nil

  private func toggle(_ action: Action? = nil) {
    self.isOpen.toggle()
    self.selected = action
  }

  var body: some View {
    Button(action: { self.toggle(.view) }) {
      PinRow(pin: self.pin)
        .contextMenu {
          Button(action: { self.toggle(.edit) }) {
            Text("Edit")
          }
          Button(action: { self.onDelete?() }) {
            Text("Delete")
          }
        }
    }
    .sheet(isPresented: $isOpen) {
      if self.selected == .view {
        WebView(url: self.pin.link.url)
          .edgesIgnoringSafeArea(.all)
      } else if self.selected == .edit {
        PinEdit(pin: self.$pin.transaction(), onClose: {
          self.toggle()
        })
          .environmentObject(self.pinsState)
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
