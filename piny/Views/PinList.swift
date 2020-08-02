//
//  PinList.swift
//  piny
//
//  Created by John Grishin on 13/07/2020.
//  Copyright © 2020 John Grishin. All rights reserved.
//

import SwiftUI

struct PinList: View {
  @State var link: PinLink?

  var pins: [Pin] = []

  var body: some View {
    List {
      ForEach(pins) { pin in
        Button(action: {
          self.link = pin.link
        }) {
          PinRow(pin: pin).padding(.vertical, 8)
        }
      }
    }
    .sheet(item: $link, content: { link in
      WebView(url: link.url)
        .edgesIgnoringSafeArea(.all)
    })
  }
}

struct PinList_Previews: PreviewProvider {
  static var previews: some View {
    PinList(pins: PreviewContent.pins)
  }
}
