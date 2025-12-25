//
//  PinAction.swift
//  piny
//
//  Created by John Grishin on 03/08/2020.
//  Copyright © 2020 John Grishin. All rights reserved.
//

import SwiftData
import SwiftUI

struct PinActionRow: View {
  var pin: PinModel

  var onOpen: () -> Void
  var onCopy: () -> Void
  var onEdit: () -> Void
  var onShare: () -> Void
  var onDelete: () -> Void

  var body: some View {
    Button(action: onOpen) {
      PinRow(pin: pin)
        .contextMenu {
          Button(action: { onEdit() }) {
            Label("Edit", systemImage: "pencil")
          }
          Link(destination: pin.link.url) {
            Label("Open in browser", systemImage: "safari")
          }
          Button(action: { onCopy() }) {
            Label("Copy", systemImage: "document.on.document")
          }
          Button(action: { onShare() }) {
            Label("Share", systemImage: "square.and.arrow.up")
          }
          Button(role: .destructive, action: { onDelete() }) {
            Label("Delete", systemImage: "trash")
          }
        }
    }
    .buttonStyle(.plain)
    .foregroundStyle(Color.foreground)
  }
}

#Preview {
  PinActionRow(
    pin: PreviewContent.pins[0],
    onOpen: {},
    onCopy: {},
    onEdit: {},
    onShare: {},
    onDelete: {}
  )
}
