//
//  UserPinList.swift
//  piny
//
//  Created by John Grishin on 26/07/2020.
//  Copyright © 2020 John Grishin. All rights reserved.
//

import SwiftUI
import SwiftData

struct UserPinList: View {
  @Environment(AsyncPins.self) var asyncPins
  @Environment(AsyncTags.self) var asyncTags
  @Query(sort: \Pin.createdAt, order: .reverse) var pins: [Pin]
  @Query(sort: \PinTag.name, order: .forward) var tags: [PinTag]

  func load() {
    Task {
      do {
        _ = try await asyncPins.fetch()
        _ = try await asyncTags.fetch()
      } catch {
        Piny.log(error, .error)
      }
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
      tags: tags,
      onRefresh: load,
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
      .environment(AsyncPins(PreviewContent.pins))
      .environment(AsyncTags(PreviewContent.tags))
  }
}
