//
//  Placeholder.swift
//  piny
//
//  Created by J. Grishin on 07/03/2023.
//  Copyright © 2023 John Grishin. All rights reserved.
//

import SwiftUI

struct Placeholder: View {
  let text: String

  init(_ text: String) {
    self.text = text
  }

  var body: some View {
    Text(text)
      .foregroundColor(.piny.grey50)
      .variant(.primary)
  }
}

struct Placeholder_Previews: PreviewProvider {
  static var previews: some View {
    Placeholder("Placeholder")
  }
}
