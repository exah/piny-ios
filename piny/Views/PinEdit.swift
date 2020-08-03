//
//  PinEdit.swift
//  piny
//
//  Created by John Grishin on 03/08/2020.
//  Copyright © 2020 John Grishin. All rights reserved.
//

import SwiftUI
import PromiseKit

private func defaultTo<T>(
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

  var body: some View {
    VStack(spacing: 8) {
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
      .padding(.bottom, 24)
      TextField("Title", text: defaultTo($pin.title, ""))
      TextField("Description", text: defaultTo($pin.description, ""))
      Button(action: {
        if (self.$pin.hasChanges) {
          self.$pin.commit()

          firstly {
            self.pinsState.edit(
              self.pin,
              title: self.pin.title,
              description: self.pin.description
            )
          }.done { pin in
            self.onClose?()
          }.catch { error in
            log(error, .error)
          }
        } else {
          self.onClose?()
        }
      }) {
        $pin.hasChanges
          ? Text("Save")
          : Text("Close")
      }
      Spacer()
    }
    .padding(24)
  }
}
