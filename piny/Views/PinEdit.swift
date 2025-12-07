//
//  PinEdit.swift
//  piny
//
//  Created by John Grishin on 03/08/2020.
//  Copyright © 2020 John Grishin. All rights reserved.
//

import SwiftUI

private func ??<T>(
  _ a: Binding<Optional<T>>,
  _ b: T
) -> Binding<T> {
  Binding(
    get: { a.wrappedValue ?? b },
    set: { a.wrappedValue = $0 }
  )
}

struct PinEdit: View {
  @Environment(AsyncPins.self) var asyncPins
  @Transaction var pin: Pin
  @State var showRemoveAlert: Bool = false

  var tags: [PinTag]

  var onClose: (() -> Void)? = nil
  var hasChanges: Bool { $pin.hasChanges }

  func save() {
    if hasChanges {
      Task {
        do {
          try await asyncPins.edit(
            pin,
            title: pin.title,
            description: pin.desc,
            tags: pin.tags.map { $0.name }
          )
          $pin.commit()
          onClose?()
        } catch {
          $pin.rollback()
          Piny.log(error, .error)
        }
      }
    } else {
      onClose?()
    }
  }

  func remove() {
    onClose?()
    Task {
      do {
        try await asyncPins.remove(pin)
      } catch {
        Piny.log(error, .error)
      }
    }
  }

  var body: some View {
    NavigationView {
      VStack {
        VStack(spacing: 16) {
          Group {
            Input("Title", value: $pin.title ?? "")
            Input("Description", value: $pin.desc ?? "")
          }
          PinTags(tags: $pin.tags, options: tags)
        }
        Spacer()
      }
      .padding(24)
      .navigationBarTitleDisplayMode(.inline)
      .toolbar {
        ToolbarItem(placement: .navigationBarLeading) {
          Button(action: save) {
            Image(systemName: hasChanges ? "checkmark" : "xmark")
          }
        }
        ToolbarItem(placement: .principal) {
          Text(pin.link.url.absoluteString)
            .font(.headline)
            .lineLimit(1)
            .frame(maxWidth: 200)
            .truncationMode(.middle)
        }
        ToolbarItem(placement: .navigationBarTrailing) {
          HStack(spacing: 16) {
            Button(action: $pin.rollback) {
              Image(systemName: "arrow.uturn.left")
            }
            Button(action: { showRemoveAlert = true }) {
              Image(systemName: "trash")
            }.alert(isPresented: $showRemoveAlert) {
              Alert(
                title: Text("Are you sure?"),
                primaryButton: .destructive(Text("Yes"), action: remove),
                secondaryButton: .cancel(Text("No"), action: { showRemoveAlert = false })
              )
            }
          }
        }
      }
    }
  }
}

struct PinEdit_Previews: PreviewProvider {
  @State static var pin = PreviewContent.pins[0]

  static var previews: some View {
    PinEdit(pin: $pin.transaction(), tags: [])
      .environment(AsyncPins())
      .environment(AsyncTags())
  }
}
