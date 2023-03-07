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
    
    @ViewBuilder func body(content: Content) -> some View {
      switch variant {
      case .primary: content.foregroundColor(Color.piny.background.opacity(opacity)).background(Color.piny.foreground)
      case .secondary: content.foregroundColor(Color.piny.foreground.opacity(opacity)).background(Color.piny.background)
      case .destructive: content.foregroundColor(Color.piny.white.opacity(opacity)).background(Color.piny.red)
      }
    }
  }
}

enum ButtonSize {
  case medium
  case small
  
  struct Modifier: ViewModifier {
    let variant: ButtonSize
    
    @ViewBuilder func body(content: Content) -> some View {
      switch variant {
      case .medium: content.padding(12)
      case .small: content.padding(6)
      }
    }
  }
}

struct PinyButtonStyle: ButtonStyle {
  let color: ButtonColor
  let size: ButtonSize
  let icon: Image?

  func makeBody(configuration: Configuration) -> some View {
    HStack(spacing: size == ButtonSize.medium ? 8 : 4) {
      icon?.textStyle(.primary)
      configuration.label.padding(.horizontal, 4)
    }
      .buttonSize(size)
      .buttonColor(color, isPressed: configuration.isPressed)
      .textStyle(.primary)
      .cornerRadius(20)
      .shadow(color: .black.opacity(0.16), radius: configuration.isPressed ? 8 : 16)
  }
}

extension View {
  func buttonColor(_ color: ButtonColor, isPressed: Bool = false) -> some View {
    modifier(ButtonColor.Modifier(variant: color, isPressed: isPressed))
  }
  
  func buttonSize(_ size: ButtonSize) -> some View {
    modifier(ButtonSize.Modifier(variant: size))
  }
  
  func buttonVariant(_ color: ButtonColor, size: ButtonSize, icon: Image? = nil) -> some View {
    buttonStyle(PinyButtonStyle(color: color, size: size, icon: icon))
  }
}

extension Button {
  func variant(_ color: ButtonColor, size: ButtonSize = .medium, icon: Image? = nil) -> some View {
    buttonVariant(color, size: size, icon: icon)
  }
}
