//
//  QuickAdd.swift
//  pinyAdd
//
//  Created by John Grishin on 26/07/2020.
//  Copyright © 2020 John Grishin. All rights reserved.
//

import SwiftUI
import PromiseKit
import MobileCoreServices

private enum QuickAddError: Error {
  case invalidInput
  case invalidResult
  case invalidURL
  case noAttachments
  case noResult
}

struct QuickAdd: View {
  @EnvironmentObject var userState: UserState
  @EnvironmentObject var pinsState: PinsState
  @State var isError: Bool = false

  let context: NSExtensionContext
  let timeout: Double = 2
  var isSuccess: Bool {
    !self.pinsState.isLoading && !isError
  }

  func handleAppear() {
    guard let user = self.userState.user else {
      return
    }

    firstly {
      self.getInput()
    }
    .then { page in
      self.pinsState.create(
        for: user,
        title: page.title,
        url: page.url,
        privacy: .Public
      ).map { _ in
        page
      }
    }
    .done { page in
      log("Shared: \(page.url) <3")
    }
    .catch { error in
      self.isError = true

      log(error, .error)
    }
  }

  func handleComplete() {
    self.context.completeRequest(returningItems: nil) { _ in
      log("Done")
    }
  }

  func getInput() -> Promise<ParsedPage> {
    guard let inputItems = self.context.inputItems as? [NSExtensionItem] else {
      return Promise(error: QuickAddError.invalidInput)
    }

    for item in inputItems {
      guard let attachments = item.attachments else {
        return Promise(error: QuickAddError.noAttachments)
      }

      for provider in attachments {
        if let promise = self.getPage(provider) {
          return promise
        }
      }
    }

    return Promise(error: QuickAddError.noResult)
  }

  private func getPage(_ provider: NSItemProvider) -> Promise<ParsedPage>? {
    let typePropertyList = String(kUTTypePropertyList)

    if provider.hasItemConformingToTypeIdentifier(typePropertyList) {
      return Promise { seal in
        provider.loadItem(forTypeIdentifier: typePropertyList) { item, error in
          if
            let dictionary = item as? NSDictionary,
            let result = dictionary[NSExtensionJavaScriptPreprocessingResultsKey] as? [String: String],
            let pageURL = URL(string: result["url"]!)
          {
            seal.fulfill(ParsedPage(title: result["title"], url: pageURL))
          } else {
            seal.reject(QuickAddError.invalidResult)
          }
        }
      }
    }

    return nil
  }

  var body: some View {
    GeometryReader { geometry in
      VStack {
        Spacer()
        HStack(alignment: .center, spacing: 16) {
          Image(
            systemName:
              self.pinsState.isLoading
                ? "clock.fill"
                : self.isError
                  ? "xmark.circle.fill"
                  : "checkmark.circle.fill"
          )
            .resizable()
            .aspectRatio(contentMode: .fit)
            .foregroundColor(
              self.pinsState.isLoading
                ? .orange
                : self.isError
                  ? .red
                  : .green
            )
            .frame(width: 24)
          Text(
            self.pinsState.isLoading
              ? "Adding..."
              : self.isError
                ? "Failed"
                : "Added to Piny"
          )
            .font(.system(size: 18))
            .fontWeight(.semibold)
            .foregroundColor(.black)
          Spacer()
          if !self.pinsState.isLoading {
            Button(action: self.handleComplete) {
              Text("Close")
                .font(.system(size: 14))
                .fontWeight(.medium)
            }
            .buttonStyle(ShapedButtonStyle(color: .blue))
          }
        }
        .padding(.horizontal, 20)
        .frame(
          width: geometry.size.width - 18,
          height: 72
        )
        .background(
          RoundedRectangle(cornerRadius: 32, style: .continuous)
            .fill(Color.white)
        )
      }
      .padding(.horizontal, 18)
      .onAppear(perform: self.handleAppear)
    }
  }
}

struct QuickAdd_Previews: PreviewProvider {
  static var previews: some View {
    QuickAdd(context: NSExtensionContext())
      .environmentObject(UserState())
      .environmentObject(PinsState([]))
      .previewLayout(PreviewLayout.sizeThatFits)
      .background(Color.gray)
  }
}
