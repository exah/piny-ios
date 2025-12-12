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

struct Input: View {
  let placeholder: String
  let type: InputType
  let variant: TextFieldColor
  let size: TextFieldSize

  @Binding
  var value: String

  init(
    _ placeholder: String = "",
    type: InputType = .text,
    value: Binding<String>,
    variant: TextFieldColor = .primary,
    size: TextFieldSize = .medium
  ) {
    self._value = value
    self.type = type
    self.placeholder = placeholder
    self.variant = variant
    self.size = size
  }

  var body: some View {
    switch type {
      case .text:
        TextField(text: $value) { label }
          .variant(variant)
      case .password:
        SecureField(text: $value) { label }
          .variant(variant)
    }
  }

  var label: some View {
    Placeholder(placeholder)
  }
}

struct Input_Previews: PreviewProvider {
  static var previews: some View {
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
      .cornerRadius(20)

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
      .cornerRadius(20)
    }
    .padding(8)
  }
}
