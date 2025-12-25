//
//  PinList.swift
//  piny
//
//  Created by John Grishin on 13/07/2020.
//  Copyright © 2020 John Grishin. All rights reserved.
//

import SwiftData
import SwiftUI

private enum Action: Equatable {
  case edit(_ pin: PinModel)
  case view(_ pin: PinModel)
  case share(_ pin: PinModel)
  case none
}

struct PinList: View {
  var pins: [PinModel]
  var onRefresh: () async -> Void
  var onDelete: (_ pin: PinModel) -> Void

  @State
  private var selected: Action = .none
  private func toggle(_ action: Action) { self.selected = action }
  private func copy(url: URL) { UIPasteboard.general.string = url.absoluteString }

  var body: some View {
    List {
      ForEach(pins, id: \.id) { pin in
        PinActionRow(
          pin: pin,
          onOpen: { toggle(.view(pin)) },
          onCopy: { copy(url: pin.link.url) },
          onEdit: { toggle(.edit(pin)) },
          onShare: { toggle(.share(pin)) },
          onDelete: { onDelete(pin) }
        )
        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
          Button {
            toggle(.edit(pin))
          } label: {
            Label("Edit", systemImage: "pencil")
          }
          .tint(.indigo)
          Button(role: .destructive) {
            onDelete(pin)
          } label: {
            Label("Delete", systemImage: "trash.fill")
          }
        }
        .swipeActions(edge: .leading, allowsFullSwipe: true) {
          Link(destination: pin.link.url) {
            Label("Open in browser", systemImage: "safari")
          }
          .tint(.green)
          Button(action: { copy(url: pin.link.url) }) {
            Label("Copy", systemImage: "document.on.document")
          }
          .tint(.indigo)
        }
      }
    }
    .sheet(
      isPresented: Binding(
        get: { selected != .none },
        set: { _ in selected = .none }
      )
    ) {
      switch selected {
        case .view(let pin):
          WebView(url: pin.link.url)
            .edgesIgnoringSafeArea(.all)
        case .share(let pin):
          ShareView(url: pin.link.url)
        case .edit(let pin):
          PinEditForm(
            pin: pin,
            title: pin.title,
            description: pin.desc,
            tags: pin.tags,
            privacy: pin.privacy,
            onClose: { toggle(.none) }
          )
        case .none:
          EmptyView()
      }
    }
    .refreshable {
      await onRefresh()
    }
  }
}

#Preview {
  PinList(
    pins: PreviewContent.pins,
    onRefresh: {},
    onDelete: { _ in }
  )
}
