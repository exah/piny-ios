//
//  TextStyle.swift
//  piny
//
//  Created by J. Grishin on 05/03/2023.
//  Copyright © 2023 John Grishin. All rights reserved.
//

import SwiftUI

enum Typography {
  case h1, h2, h3
  case primary, secondary, tertiary
  case mono
  
  struct Modifier: ViewModifier {
    let variant: Typography
    
    @ViewBuilder func body(content: Content) -> some View {
      switch variant {
      case .h1: content.font(.system(size: 28, weight: .semibold)).frame(minHeight: 40)
      case .h2: content.font(.system(size: 22, weight: .semibold)).frame(minHeight: 32)
      case .h3: content.font(.system(size: 18, weight: .semibold)).frame(minHeight: 24)
      case .primary: content.font(.system(size: 16, weight: .medium))
      case .secondary: content.font(.system(size: 14, weight: .medium))
      case .tertiary: content.font(.system(size: 12, weight: .regular))
      case .mono: content.font(.system(size: 16, weight: .regular, design: .monospaced))
      }
    }
  }
}

extension View {
  func textStyle(_ variant: Typography) -> some View {
    modifier(Typography.Modifier(variant: variant))
  }
}

extension Text {
  func variant(_ variant: Typography) -> some View {
    textStyle(variant)
  }
}
