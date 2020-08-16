//
//  PinEdit.swift
//  piny
//
//  Created by John Grishin on 03/08/2020.
//  Copyright © 2020 John Grishin. All rights reserved.
//

import SwiftUI
import PromiseKit

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
  @EnvironmentObject var pinsState: PinsState
  @Transaction var pin: Pin

  var onClose: (() -> Void)? = nil

  func save() {
    if (self.$pin.hasChanges) {
      firstly {
        self.pinsState.edit(
          self.pin,
          title: self.pin.title,
          description: self.pin.description,
          tags: self.pin.tags.map { $0.name }
        )
      }.done { pin in
        self.$pin.commit()
        self.onClose?()
      }.catch { error in
        self.$pin.rollback()
        log(error, .error)
      }
    } else {
      self.onClose?()
    }
  }

  var body: some View {
    VStack {
      HStack {
        Text("Edit bookmark").font(.title)
        Spacer()
        if ($pin.hasChanges) {
          Button(action: {
            self.$pin.rollback()
          }) {
            Text("Reset")
          }
        }
      }
      VStack(spacing: 24) {
        VStack(spacing: 8) {
          Group {
            TextField("Title", text: $pin.title ?? "")
            TextField("Description", text: $pin.description ?? "")
          }
            .textFieldStyle(ShapedTextFieldStyle())
          TagsField(tags: $pin.tags)
            .frame(height: UIFont.preferredFont(forTextStyle: .body).pointSize + 22)
        }
        Button(action: self.save) {
          $pin.hasChanges ? Text("Save") : Text("Close")
        }
      }
      Spacer()
    }
    .padding(24)
  }
}

struct PinEdit_Previews: PreviewProvider {
  @State static var pin = PreviewContent.pins[0]

  static var previews: some View {
    PinEdit(pin: self.$pin.transaction())
      .environmentObject(PinsState())
  }
}
