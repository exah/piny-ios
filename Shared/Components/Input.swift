//
//  Input.swift
//  piny
//
//  Created by J. Grishin on 06/03/2023.
//  Copyright © 2023 John Grishin. All rights reserved.
//

import SwiftUI

enum InputType {
  case text, password
}

struct Input<Leading: View, Trailing: View>: View {
  let placeholder: String
  let type: InputType
  let variant: TextFieldColor
  let size: TextFieldSize
  let leading: () -> Leading
  let trailing: () -> Trailing

  @Binding
  var value: String

  init(
    _ placeholder: String = "",
    type: InputType = .text,
    value: Binding<String>,
    variant: TextFieldColor = .primary,
    size: TextFieldSize = .medium,
    @ViewBuilder leading: @escaping () -> Leading = { EmptyView() },
    @ViewBuilder trailing: @escaping () -> Trailing = { EmptyView() }
  ) {
    self._value = value
    self.type = type
    self.placeholder = placeholder
    self.variant = variant
    self.size = size
    self.leading = leading
    self.trailing = trailing
  }

  var body: some View {
    switch type {
      case .text:
        TextField(text: $value) { label }
          .variant(variant, size: size, leading: leading, trailing: trailing)
      case .password:
        SecureField(text: $value) { label }
          .variant(variant, size: size, leading: leading, trailing: trailing)
    }
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
      Input("Placeholder", type: .password, value: .constant("Value"))
    }
    .padding(.horizontal, 16)

    HStack(spacing: 12) {
      Input("Placeholder", value: .constant(""), variant: .dark)
      Input("Placeholder", value: .constant("Value"), variant: .dark)
      Input(
        "Placeholder",
        type: .password,
        value: .constant("Value"),
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
        type: .password,
        value: .constant("Value"),
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
        type: .password,
        value: .constant("Value"),
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
