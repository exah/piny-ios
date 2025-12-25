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

  @Query(sort: \PinModel.createdAt, order: .reverse)
  var pins: [PinModel]

  func handleRefresh() async {
    do {
      try await pinState.fetch()
    } catch ResponseError.unauthorized {
      try? await sessionState.logout()
    } catch {
      Piny.log(error, .error)
    }
  }

  func handleAppear() {
    Task {
      await handleRefresh()
    }
  }

  func remove(_ pin: PinModel) {
    Task {
      do {
        try await pinState.remove(pin)
      } catch {
        Piny.log(error, .error)
      }
    }
  }

  var body: some View {
    PinList(
      pins: pins,
      onRefresh: handleRefresh,
      onDelete: remove
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
