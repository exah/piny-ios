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
  @Environment(AsyncPins.self)
  var asyncPins

  @Environment(AsyncTags.self)
  var asyncTags

  @Environment(AsyncUser.self)
  var asyncUser

  @Query(sort: \Pin.createdAt, order: .reverse)
  var pins: [Pin]

  func handleRefresh() async {
    do {
      try await asyncPins.fetch()
    } catch ResponseError.unauthorized {
      asyncUser.deleteAllData()
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
          try await asyncPins.remove(pin)
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
    .environment(AsyncPins(PreviewContent.pins))
    .environment(AsyncTags(PreviewContent.tags))
    .environment(AsyncUser(PreviewContent.user))
}
