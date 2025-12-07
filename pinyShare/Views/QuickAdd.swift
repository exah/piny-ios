//
//  QuickAdd.swift
//  pinyAdd
//
//  Created by John Grishin on 26/07/2020.
//  Copyright © 2020 John Grishin. All rights reserved.
//

import SwiftUI
import MobileCoreServices

enum QuickAddError: Error {
  case invalidInput
  case invalidResult
  case invalidURL
  case noAttachments
  case noResult
}

struct QuickAdd: View {
  @Environment(AsyncUser.self) var asyncUser
  @Environment(AsyncPins.self) var asyncPins
  @State var isError: Bool = false

  let page: ParsedPage
  let onComplete: () -> Void
  let timeout: Double = 2
  var isSuccess: Bool {
    !self.asyncPins.isLoading && !isError
  }

  func handleAppear() {
    Task {
      do {
        try await asyncPins.create(
          title: page.title,
          url: page.url,
          privacy: .public
        )
        Piny.log("Shared: \(page.url) <3")
      } catch {
        isError = true
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
            self.asyncPins.isLoading
          ? "circle.dotted"
          : isError
          ? "xmark.circle.fill"
          : "globe"
        )
        .resizable()
        .aspectRatio(contentMode: .fit)
        .foregroundColor(
          isError
          ? .piny.red
          : .piny.foreground
        )
        .frame(width: 16, height: 16)
      }
      .frame(width: 24, height: 24)
      Text(
        self.asyncPins.isLoading
        ? "Adding..."
        : isError
        ? "Failed to add"
        : "Added to Piny"
      )
      .variant(.h2)
      .foregroundColor(
        isError
        ? .piny.red
        : .piny.foreground
      )
      Spacer()
      if !self.asyncPins.isLoading && !isError {
        Button(action: onComplete) {}
          .variant(.primary, size: .small, icon: Image(systemName: "checkmark"))
      }
    }
    .padding(12)
    .background(
      isError
      ? Color.piny.red10
      : Color.piny.level48
    )
    .cornerRadius(40)
    .onAppear(perform: self.handleAppear)
  }
}

#Preview(traits: .sizeThatFitsLayout) {
  QuickAdd(page: ParsedPage(title: "Example", url: URL(string: "http://example.com")!), onComplete: {})
    .environment(AsyncUser())
    .environment(AsyncPins())
}
