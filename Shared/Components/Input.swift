//
//  Input.swift
//  piny
//
//  Created by J. Grishin on 06/03/2023.
//  Copyright © 2023 John Grishin. All rights reserved.
//

import SwiftUI

enum InputType {
  case text, password, editor
}

func getDefaultSize(_ type: InputType) -> TextFieldSize {
  switch type {
    case .text: .medium
    case .password: .medium
    case .editor: .textEditor
  }
}

struct Input<Leading: View, Trailing: View>: View {
  let placeholder: String
  let type: InputType
  let variant: TextFieldColor
  let size: TextFieldSize
  let axis: Axis?
  let invalid: Bool
  let message: String?
  let leading: () -> Leading
  let trailing: () -> Trailing

  @Binding
  var value: String

  init(
    _ placeholder: String = "",
    value: Binding<String>,
    type: InputType = .text,
    variant: TextFieldColor = .primary,
    size: TextFieldSize? = nil,
    axis: Axis? = nil,
    invalid: Bool = false,
    message: String? = nil,
    @ViewBuilder leading: @escaping () -> Leading = { EmptyView() },
    @ViewBuilder trailing: @escaping () -> Trailing = { EmptyView() }
  ) {
    self._value = value
    self.type = type
    self.axis = axis
    self.placeholder = placeholder
    self.variant = variant
    self.size = size ?? getDefaultSize(type)
    self.invalid = invalid
    self.message = message
    self.leading = leading
    self.trailing = trailing
  }

  var body: some View {
    Group {
      switch type {
        case .text:
          if let axis = axis {
            TextField(text: $value, axis: axis, label: { label })
          } else {
            TextField(text: $value, label: { label })
          }
        case .password:
          SecureField(text: $value) { label }
        case .editor:
          TextEditor(text: $value)
            .scrollContentBackground(.hidden)
      }
    }
    .textFieldVariant(
      variant,
      size: size,
      invalid: invalid,
      message: message,
      leading: leading,
      trailing: trailing
    )
  }

  var label: some View {
    Placeholder(placeholder)
  }
}

#Preview {
  VStack(spacing: 24) {
    HStack(spacing: 12) {
      Input("Placeholder", value: .constant(""))
      Input("Placeholder", value: .constant("Value"))
      Input("Placeholder", value: .constant("Value"), type: .password)
    }
    .padding(.horizontal, 16)

    HStack(spacing: 12) {
      Input("Placeholder", value: .constant(""), variant: .dark)
      Input("Placeholder", value: .constant("Value"), variant: .dark)
      Input(
        "Placeholder",
        value: .constant("Value"),
        type: .password,
        variant: .dark
      )
    }
    .padding(10)
    .background(.black)
    .containerShape(
      .rect(cornerRadius: 40)
    )

    HStack(spacing: 12) {
      Input("Placeholder", value: .constant(""), size: .small)
      Input("Placeholder", value: .constant("Value"), size: .small)
      Input(
        "Placeholder",
        value: .constant("Value"),
        type: .password,
        size: .small
      )
    }
    .padding(.horizontal, 16)

    HStack(spacing: 10) {
      Input("Placeholder", value: .constant(""), variant: .dark, size: .small)
      Input(
        "Placeholder",
        value: .constant("Value"),
        variant: .dark,
        size: .small
      )
      Input(
        "Placeholder",
        value: .constant("Value"),
        type: .password,
        variant: .dark,
        size: .small
      )
    }
    .padding(10)
    .background(.black)
    .containerShape(
      .rect(cornerRadius: 40)
    )
  }
  .padding(8)
}
