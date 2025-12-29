//
//  ShapedTextFieldStyle.swift
//  piny
//
//  Created by John Grishin on 27/07/2020.
//  Copyright © 2020 John Grishin. All rights reserved.
//

import SwiftUI

enum TextFieldColor {
  case primary
  case dark
}

enum TextFieldSize {
  case medium
  case tags
  case textEditor
  case small
}

struct TextFieldModifier<Leading: View, Trailing: View>: ViewModifier {
  let color: TextFieldColor
  let size: TextFieldSize
  let invalid: Bool
  let message: String?
  let leading: Leading
  let trailing: Trailing

  @FocusState
  var focused: Bool

  private var colors: (fg: Color, bg: Color, stroke: Color) {
    switch color {
      case .primary:
        return (
          fg: invalid ? .piny.red : .piny.foreground,
          bg: invalid ? .piny.red10 : focused ? .piny.blue10 : .piny.grey10,
          stroke: focused ? invalid ? .piny.red : .piny.blue : .clear
        )
      case .dark:
        return (
          fg: invalid ? .piny.red : .piny.foreground,
          bg: invalid ? .piny.red10 : focused ? .piny.grey20 : .piny.grey10,
          stroke: focused ? invalid ? .piny.red : .piny.foreground : .clear
        )
    }
  }

  private var padding: (x: Double, y: Double) {
    switch size {
      case .medium: return (16, 8)
      case .tags: return (8, 8)
      case .textEditor: return (12, 2)
      case .small: return (8, 2)
    }
  }

  private var height: Double {
    switch size {
      case .medium: return 40
      case .tags: return 40
      case .textEditor: return 40
      case .small: return 20
    }
  }

  @ViewBuilder
  func base(_ content: Content) -> some View {
    HStack(alignment: .center) {
      HStack(alignment: .center, spacing: 8) {
        leading
        content
        if let message = message {
          Spacer()
          Text(message)
            .variant(.secondary)
            .foregroundColor(invalid ? .piny.red : .piny.foreground)
        }
        trailing
      }
      .padding(.horizontal, 4)
      .frame(minHeight: 24)
    }
    .padding(.horizontal, padding.x)
    .padding(.vertical, padding.y)
    .frame(minHeight: height)
    .foregroundColor(colors.fg)
    .background(
      colors.bg,
      in: .rect(
        corners: .concentric(minimum: 20),
        isUniform: true
      )
    )
    .overlay(
      ConcentricRectangle(
        corners: .concentric(minimum: 20),
        isUniform: true
      )
      .stroke(
        colors.stroke,
        lineWidth: size == .medium ? 2 : 1.5
      )
      .ignoresSafeArea()
    )
    .focused($focused)
    .textStyle(.primary)
  }

  @ViewBuilder
  func colored(_ content: Content) -> some View {
    switch color {
      case .dark: base(content).environment(\.colorScheme, .dark)
      default: base(content)
    }
  }

  func body(content: Content) -> some View {
    colored(content)
  }
}

extension View {
  func textFieldVariant<Leading: View, Trailing: View>(
    _ color: TextFieldColor,
    size: TextFieldSize = .medium,
    invalid: Bool = false,
    message: String? = nil,
    @ViewBuilder leading: () -> Leading = { EmptyView() },
    @ViewBuilder trailing: () -> Trailing = { EmptyView() }
  ) -> some View {
    modifier(
      TextFieldModifier(
        color: color,
        size: size,
        invalid: invalid,
        message: message,
        leading: leading(),
        trailing: trailing()
      )
    )
  }
}

protocol TextFieldVariant {}

extension TextField: TextFieldVariant {}
extension SecureField: TextFieldVariant {}
extension TextEditor: TextFieldVariant {}

extension View where Self: TextFieldVariant {
  func variant<Leading: View, Trailing: View>(
    _ color: TextFieldColor,
    size: TextFieldSize = .medium,
    invalid: Bool = false,
    message: String? = nil,
    @ViewBuilder leading: @escaping () -> Leading = { EmptyView() },
    @ViewBuilder trailing: @escaping () -> Trailing = { EmptyView() }
  ) -> some View {
    textFieldVariant(
      color,
      size: size,
      invalid: invalid,
      message: message,
      leading: leading,
      trailing: trailing
    )
  }
}
