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
  @State var showRemoveAlert: Bool = false

  var onClose: (() -> Void)? = nil

  func save() {
    if ($pin.hasChanges) {
      firstly {
        pinsState.edit(
          pin,
          title: pin.title,
          description: pin.description,
          tags: pin.tags.map { $0.name }
        )
      }.done { pin in
        $pin.commit()
        onClose?()
      }.catch { error in
        $pin.rollback()
        Piny.log(error, .error)
      }
    } else {
      onClose?()
    }
  }

  func remove() {
    onClose?()
    pinsState.remove(pin).catch { error in
      Piny.log(error, .error)
    }
  }

  var body: some View {
    NavigationView {
      VStack {
        VStack(spacing: 16) {
          Group {
            Input("Title", value: $pin.title ?? "")
            Input("Description", value: $pin.description ?? "")
          }
          TagsField(tags: $pin.tags)
            .textFieldVariant(.primary)
            .frame(height: UIFont.preferredFont(forTextStyle: .body).pointSize + 22)
        }
        Spacer()
      }
      .padding(24)
      .navigationBarTitleDisplayMode(.inline)
      .toolbar {
        ToolbarItem(placement: .navigationBarLeading) {
          Button(action: save) {
            Image(systemName: $pin.hasChanges ? "checkmark" : "xmark")
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
    PinEdit(pin: $pin.transaction())
      .environmentObject(PinsState())
  }
}
