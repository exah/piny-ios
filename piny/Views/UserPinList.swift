//
//  UserPinList.swift
//  piny
//
//  Created by John Grishin on 26/07/2020.
//  Copyright © 2020 John Grishin. All rights reserved.
//

import SwiftUI

struct UserPinList: View {
  @EnvironmentObject var pinsState: PinsState

  var user: User
  func handleAppear() {
    pinsState.fetchPins(user: user)
  }

  var body: some View {
    VStack {
      if pinsState.isLoading {
        Text("Loading...")
      }

      PinList(pins: pinsState.pins)
        .onAppear(perform: handleAppear)
    }
  }
}

struct UserPinList_Previews: PreviewProvider {
  static var previews: some View {
    UserPinList(user: PREVIEW_USER)
      .environmentObject(PinsState(PREVIEW_PINS))
  }
}
