//
//  UserPinList.swift
//  piny
//
//  Created by John Grishin on 26/07/2020.
//  Copyright © 2020 John Grishin. All rights reserved.
//

import SwiftUI
import PromiseKit

struct UserPinList: View {
  @EnvironmentObject var pinsState: PinsState

  var user: User
  func handleAppear() {
    firstly {
      pinsState.fetch(for: user)
    }.catch { error in
      log(error, .error)
    }
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
