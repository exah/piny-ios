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

  func load() {
    firstly {
      pinsState.fetch()
    }.catch { error in
      log(error, .error)
    }
  }

  func remove(_ offsets: IndexSet) {
    for index in offsets {
      let pin = pinsState.pins[index]

      self.pinsState.remove(pin).catch { error in
        log(error, .error)
      }
    }
  }

  var body: some View {
    PinList(
      pins: pinsState.pins,
      onAppear: load,
      onDelete: remove
    )
      .onReceive(NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)) { _ in
        self.load()
      }
  }
}

struct UserPinList_Previews: PreviewProvider {
  static var previews: some View {
    UserPinList(user: PreviewContent.user)
      .environmentObject(PinsState(PreviewContent.pins))
  }
}
