//
//  PinList.swift
//  piny
//
//  Created by John Grishin on 13/07/2020.
//  Copyright © 2020 John Grishin. All rights reserved.
//

import SwiftUI

struct PinList: View {
  @EnvironmentObject var userData: UserState
  @State var link: PinLink?

  var body: some View {
    VStack {
      if userData.pinsTask?.isLoading == true {
        Text("Loading...")
      }
      List {
        ForEach(userData.pins ?? []) { pin in
          Button(action: {
            self.link = pin.link
          }) {
            PinRow(pin: pin).padding(.vertical, 8)
          }
        }
      }
    }
    .sheet(item: $link, content: { link in
      WebView(url: link.url)
        .edgesIgnoringSafeArea(.all)
    })
    .onAppear {
      self.userData.fetchPins()
    }
  }
}

struct PinList_Previews: PreviewProvider {
  static var previews: some View {
    PinList()
      .environmentObject(UserState(initialPins: PREVIEW_PINS))
  }
}
