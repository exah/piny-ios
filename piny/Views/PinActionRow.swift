//
//  PinAction.swift
//  piny
//
//  Created by John Grishin on 03/08/2020.
//  Copyright © 2020 John Grishin. All rights reserved.
//

import SwiftUI
import SwiftData

private enum Action {
  case edit
  case view
  case share
  case none
}

struct PinActionRow: View {
  @State private var selected: Action = .none
  @State var pin: Pin
  var tags: [PinTag]

  var onDelete: (() -> Void)? = nil

  private func toggle(_ action: Action) {
    self.selected = action
  }

  private func copy(url: URL) {
    UIPasteboard.general.string = url.absoluteString
  }

  var body: some View {
    Button(action: { toggle(.view) }) {
      PinRow(pin: pin, tags: tags)
        .contextMenu {
          Button(action: { toggle(.edit) }) {
            Label("Edit", systemImage: "pencil")
          }
          Link(destination: pin.link.url) {
            Label("Open in browser", systemImage: "safari")
          }
          Button(action: { copy(url: pin.link.url) }) {
            Label("Copy", systemImage: "document.on.document")
          }
          Button(action: { toggle(.share) }) {
            Label("Share", systemImage: "square.and.arrow.up")
          }
          Button(role: .destructive, action: { onDelete?() }) {
            Label("Delete", systemImage: "trash")
          }
        }
    }
    .foregroundStyle(Color.foreground)
    .sheet(isPresented: Binding(get: { selected != .none }, set: { _ in selected = .none })) {
      switch selected {
        case .view:
          WebView(url: pin.link.url)
            .edgesIgnoringSafeArea(.all)
        case .share:
          ShareView(url: pin.link.url)
        case .edit:
          PinEdit(
            pin: $pin.transaction(),
            tags: tags,
            onClose: { toggle(.none) }
          )
        case .none:
          EmptyView()
      }
    }
  }
}

struct PinAction_Previews: PreviewProvider {
  static var previews: some View {
    PinActionRow(pin: PreviewContent.pins[0], tags: [])
  }
}
