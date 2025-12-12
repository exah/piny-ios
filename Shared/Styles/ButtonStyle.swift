//
//  ShapedButtonStyle.swift
//  piny
//
//  Created by John Grishin on 27/07/2020.
//  Copyright © 2020 John Grishin. All rights reserved.
//

import SwiftUI

enum ButtonColor {
  case primary
  case secondary
  case destructive

  struct Modifier: ViewModifier {
    let variant: ButtonColor
    let isPressed: Bool
    var opacity: Double { isPressed ? 0.5 : 1 }

    @ViewBuilder
    func body(content: Content) -> some View {
      switch variant {
        case .primary:
          content.foregroundColor(Color.piny.background.opacity(opacity))
            .background(Color.piny.foreground)
        case .secondary:
          content.foregroundColor(Color.piny.foreground.opacity(opacity))
            .background(Color.piny.background)
        case .destructive:
          content.foregroundColor(Color.piny.white.opacity(opacity))
            .background(Color.piny.red)
      }
    }
  }
}

enum ButtonSize {
  case medium
  case small
  case tag

  struct Modifier: ViewModifier {
    let variant: ButtonSize
    let hug: Bool

    @ViewBuilder
    func body(content: Content) -> some View {
      switch variant {
        case .medium: content.textStyle(.primary).padding(12)
        case .small: content.textStyle(.primary).padding(6)
        case .tag:
          content.textStyle(.secondary).padding(.horizontal, hug ? 1 : 8)
            .padding(.vertical, 1)
      }
    }
  }
}

struct PinyButtonStyle: ButtonStyle {
  let color: ButtonColor
  let size: ButtonSize
  let icon: Image?
  let hug: Bool?

  func makeBody(configuration: Configuration) -> some View {
    HStack(spacing: size == ButtonSize.medium ? 8 : 4) {
      icon?.textStyle(.primary)
      configuration.label.padding(.horizontal, 4)
    }
    .buttonSize(size, hug: hug ?? false)
    .buttonColor(color, isPressed: configuration.isPressed)
    .cornerRadius(20)
    .shadow(
      color: .black.opacity(0.16),
      radius: configuration.isPressed ? 8 : 16
    )
  }
}

extension View {
  func buttonColor(_ color: ButtonColor, isPressed: Bool = false) -> some View {
    modifier(ButtonColor.Modifier(variant: color, isPressed: isPressed))
  }

  func buttonSize(_ size: ButtonSize, hug: Bool = false) -> some View {
    modifier(ButtonSize.Modifier(variant: size, hug: hug))
  }

  func buttonVariant(
    _ color: ButtonColor,
    size: ButtonSize,
    icon: Image? = nil,
    hug: Bool = false
  ) -> some View {
    buttonStyle(PinyButtonStyle(color: color, size: size, icon: icon, hug: hug))
  }
}

extension Button {
  func variant(
    _ color: ButtonColor,
    size: ButtonSize = .medium,
    icon: Image? = nil,
    hug: Bool = false
  ) -> some View {
    buttonVariant(color, size: size, icon: icon, hug: hug)
  }
}
