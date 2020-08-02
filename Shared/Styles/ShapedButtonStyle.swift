//
//  ShapedButtonStyle.swift
//  piny
//
//  Created by John Grishin on 27/07/2020.
//  Copyright © 2020 John Grishin. All rights reserved.
//

import SwiftUI

struct ShapedButtonStyle: ButtonStyle {
  let color: Color

  func makeBody(configuration: Self.Configuration) -> some View {
    configuration.label
      .buttonStyle(BorderlessButtonStyle())
      .foregroundColor(color)
      .padding(.horizontal, 16)
      .padding(.vertical, 8)
      .background(
        RoundedRectangle(cornerRadius: 16, style: .continuous)
          .fill(color)
          .opacity(0.1)
      )
  }
}
