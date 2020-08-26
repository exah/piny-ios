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

  func load() {
    firstly {
      pinsState.fetch()
    }.catch { error in
      Piny.log(error, .error)
    }
  }

  func remove(_ pins: [Pin]) {
    for pin in pins {
      self.pinsState.remove(pin).catch { error in
        Piny.log(error, .error)
      }
    }
  }

  var body: some View {
    PinList(
      pins: pinsState.pins,
      onDelete: remove
    )
      .onAppear(perform: load)
      .onReceive(NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)) { _ in
        self.load()
      }
  }
}

struct UserPinList_Previews: PreviewProvider {
  static var previews: some View {
    UserPinList()
      .environmentObject(PinsState(PreviewContent.pins))
  }
}
