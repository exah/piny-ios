//
//  PinList.swift
//  piny
//
//  Created by John Grishin on 13/07/2020.
//  Copyright © 2020 John Grishin. All rights reserved.
//

import SwiftUI

struct PinList: View {
  @EnvironmentObject var userData: UserData
  
  @State var link: PinLink?
  @State var isLoading: Bool = false

  var body: some View {
    VStack {
      if isLoading {
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
      WebView(url: URL(string: link.url)!)
        .edgesIgnoringSafeArea(.all)
    })
    .onAppear {
      self.isLoading = true
      self.userData.fetchUserPins() {
        self.isLoading = false
      }
    }
  }
}

struct PinList_Previews: PreviewProvider {
  static var previews: some View {
    PinList()
      .environmentObject(UserData(pins: PREVIEW_PINS))
  }
}
