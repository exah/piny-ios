//
//  QuickAdd.swift
//  pinyAdd
//
//  Created by John Grishin on 26/07/2020.
//  Copyright © 2020 John Grishin. All rights reserved.
//

import SwiftUI

enum QuickAddError: Error {
  case invalidInput
  case pageParseFailed
  case invalidResult
  case invalidURL
  case noAttachments
  case noResult
}

struct QuickAdd: View {
  @Environment(SessionState.self)
  var sessionState

  @Environment(PinState.self)
  var pinState

  let page: ParsedPage
  let onComplete: () -> Void
  let timeout: Double = 2

  func handleAppear() {
    Task {
      do {
        try await pinState.create(
          title: page.title,
          url: page.url,
          privacy: .public
        )
        Piny.log("Shared: \(page.url) <3")
      } catch {
        Piny.log(error, .error)
      }

      try? await Task.sleep(nanoseconds: UInt64(timeout * 1_000_000_000))
      onComplete()
    }
  }

  var body: some View {
    HStack(alignment: .center, spacing: 12) {
      Group {
        Image(
          systemName:
            pinState.result.create.isLoading
            ? "circle.dotted"
            : pinState.result.create.isError
              ? "xmark.circle.fill"
              : "globe"
        )
        .resizable()
        .aspectRatio(contentMode: .fit)
        .foregroundColor(
          pinState.result.create.isError
            ? .piny.red
            : .piny.foreground
        )
        .frame(width: 16, height: 16)
      }
      .frame(width: 24, height: 24)
      Text(
        pinState.result.create.isLoading
          ? "Adding..."
          : pinState.result.create.isError
            ? "Failed to add"
            : "Added to Piny"
      )
      .variant(.h2)
      .foregroundColor(
        pinState.result.create.isError
          ? .piny.red
          : .piny.foreground
      )
      Spacer()
      if pinState.result.create.isSuccess {
        Button(action: onComplete) {}
          .variant(.primary, size: .small, icon: Image(systemName: "checkmark"))
      }
    }
    .padding(12)
    .background(
      pinState.result.create.isError
        ? Color.piny.red10
        : Color.piny.level48
    )
    .cornerRadius(40)
    .onAppear(perform: self.handleAppear)
  }
}

#Preview(traits: .sizeThatFitsLayout) {
  QuickAdd(
    page: ParsedPage(title: "Example", url: URL(string: "http://example.com")!),
    onComplete: {}
  )
  .environment(SessionState())
  .environment(PinState())
}
