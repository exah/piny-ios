//
//  ShapedTextFieldStyle.swift
//  piny
//
//  Created by John Grishin on 27/07/2020.
//  Copyright © 2020 John Grishin. All rights reserved.
//

import SwiftUI

enum TextFieldColor {
  case light
  case dark
}

enum TextFieldSize {
  case medium
  case small
}

struct PinyTextFieldStyle: TextFieldStyle {
  let color: TextFieldColor
  let size: TextFieldSize
  let invalid: Bool
  let radius: Double = 20
  
  @FocusState var focused: Bool
  
  private var colors: (fg: Color, bg: Color, stroke: Color) {
    switch color {
    case .light:
      return (
        fg: invalid ? .red : .black,
        bg: invalid
          ? Color(red: 1, green: 0.93, blue: 0.93)
          : focused
            ? Color(red: 0.95, green: 0.98, blue: 1.0)
            : Color(red: 0.93, green: 0.93, blue: 0.93),
        stroke: focused
          ? invalid
            ? .red
            : .blue
          : .black.opacity(0)
      )
    case .dark:
      return (
        fg: .white,
        bg: Color(red: 0.13, green: 0.13, blue: 0.13),
        stroke: focused ? .white : .white.opacity(0)
      )
    }
  }
  
  private var padding: (x: Double, y: Double) {
    switch size {
    case .medium: return (16, 8)
    case .small: return (8, 2)
    }
  }
  
  func _body(configuration: TextField<_Label>) -> some View {
    HStack {
      configuration
        .padding(.horizontal, 4)
    }
      .padding(.horizontal, padding.x)
      .padding(.vertical, padding.y)
      .foregroundColor(colors.fg)
      .background(colors.bg)
      .cornerRadius(radius)
      .overlay(
        RoundedRectangle(cornerRadius: radius, style: .continuous)
          .stroke(colors.stroke, lineWidth: size == .medium ? 2 : 1.5)
      )
      .focused($focused)
      .textStyle(.primary)
  }
}

extension View {
  func textFieldVariant(_ color: TextFieldColor, size: TextFieldSize = .medium, invalid: Bool = false) -> some View {
    textFieldStyle(PinyTextFieldStyle(color: color, size: size, invalid: invalid))
  }
}

protocol TextFieldVariant {}

extension TextField: TextFieldVariant {}
extension SecureField: TextFieldVariant {}

extension View where Self: TextFieldVariant {
  func variant(_ color: TextFieldColor, size: TextFieldSize = .medium, invalid: Bool = false) -> some View {
    textFieldVariant(color, size: size, invalid: invalid)
  }
}
