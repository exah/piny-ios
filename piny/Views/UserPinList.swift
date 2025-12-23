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
  @Environment(PinsState.self)
  var pinsState

  @Environment(TagsState.self)
  var tagsState

  @Environment(UserState.self)
  var userState

  @Query(sort: \Pin.createdAt, order: .reverse)
  var pins: [Pin]

  func handleRefresh() async {
    do {
      try await pinsState.fetch()
    } catch ResponseError.unauthorized {
      try? await userState.deleteAllData()
    } catch {
      Piny.log(error, .error)
    }
  }

  func handleAppear() {
    Task {
      await handleRefresh()
    }
  }

  func remove(_ pins: [Pin]) {
    for pin in pins {
      Task {
        do {
          try await pinsState.remove(pin)
        } catch {
          Piny.log(error, .error)
        }
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
    .environment(PinsState(PreviewContent.pins))
    .environment(TagsState(PreviewContent.tags))
    .environment(UserState(PreviewContent.user))
}
