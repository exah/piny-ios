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
    pinsState.fetch(for: user)
  }

  var body: some View {
    PinList(pins: pinsState.pins)
      .onAppear(perform: handleAppear)
      .onReceive(NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)) { _ in
        self.handleAppear()
      }
  }
}

struct UserPinList_Previews: PreviewProvider {
  static var previews: some View {
    UserPinList(user: PREVIEW_USER)
      .environmentObject(PinsState(PREVIEW_PINS))
  }
}
