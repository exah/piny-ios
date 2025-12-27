//
//  UserPinList.swift
//  piny
//
//  Created by John Grishin on 26/07/2020.
//  Copyright © 2020 John Grishin. All rights reserved.
//

import SwiftData
import SwiftUI

struct UserPinList: View {
  @Environment(PinState.self)
  var pinState

  @Environment(TagState.self)
  var tagState

  @Environment(SessionState.self)
  var sessionState

  @Query(PinActor.Descriptors.all())
  var pins: [PinModel]

  func handleUnauthorized() {
    Task {
      try await sessionState.logout()
    }
  }

  func handleRefresh() async {
    do {
      try await pinState.fetch()
    } catch ResponseError.unauthorized {
      Task {
        try await sessionState.logout()
      }
    } catch {}
  }

  func handleAppear() {
    Task {
      await handleRefresh()
    }
  }

  func handleDelete(_ pin: PinModel) {
    Task {
      try await pinState.delete(pin)
    }
  }

  var body: some View {
    PinList(
      pins: pins,
      onRefresh: handleRefresh,
      onDelete: handleDelete
    )
    .onAppear(perform: handleAppear)
    .onReceive(
      NotificationCenter.default.publisher(
        for: UIApplication.willEnterForegroundNotification
      )
    ) { _ in
      handleAppear()
    }
  }
}

#Preview {
  UserPinList()
    .environment(PinState(PreviewContent.pins))
    .environment(TagState(PreviewContent.tags))
    .environment(SessionState(PreviewContent.user))
}
