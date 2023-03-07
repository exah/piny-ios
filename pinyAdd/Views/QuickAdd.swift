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
    firstly {
      self.getInput()
    }
    .then { page in
      self.pinsState.create(
        title: page.title,
        url: page.url,
        privacy: .public
      ).map { _ in
        page
      }
    }
    .done { page in
      Piny.log("Shared: \(page.url) <3")
    }
    .catch { error in
      self.isError = true

      Piny.log(error, .error)
    }
    .finally {
      DispatchQueue.main.asyncAfter(deadline: .now() + self.timeout) {
        self.handleComplete()
      }
    }
  }

  func handleComplete() {
    self.context.completeRequest(returningItems: nil) { _ in
      Piny.log("Done")
    }
  }

  func getInput() -> Promise<ParsedPage> {
    guard let inputItems = self.context.inputItems as? [NSExtensionItem] else {
      return Promise(error: QuickAddError.invalidInput)
    }

    let promises = inputItems.compactMap { item in
      return item.attachments?.map { provider in
        firstly {
          self.getPage(provider)
        }.recover { _ in
          self.getURL(provider)
        }
      }
    }

    return race(Array(promises.joined()))
  }

  private func loadItem(_ identifier: String, in provider: NSItemProvider) -> Promise<NSSecureCoding?> {
    if provider.hasItemConformingToTypeIdentifier(identifier) {
      return Promise { seal in
        provider.loadItem(forTypeIdentifier: identifier) { item, error in
          if let error = error {
            return seal.reject(error)
          } else {
            return seal.fulfill(item)
          }
        }
      }
    }

    return Promise(error: QuickAddError.noResult)
  }

  private func getPage(_ provider: NSItemProvider) -> Promise<ParsedPage> {
    firstly {
      loadItem(String(kUTTypePropertyList), in: provider)
    }.map { item in
      if
        let dict = item as? NSDictionary,
        let data = dict[NSExtensionJavaScriptPreprocessingResultsKey] as? [String: String],
        let pageURL = URL(string: data["url"]!)
      {
        return ParsedPage(title: data["title"], url: pageURL)
      } else {
        throw QuickAddError.invalidResult
      }
    }
  }

  private func getURL(_ provider: NSItemProvider) -> Promise<ParsedPage> {
    firstly {
      loadItem(String(kUTTypeURL), in: provider)
    }.map { item in
      if let url = item as? URL {
        return ParsedPage(title: nil, url: url)
      } else {
        throw QuickAddError.invalidResult
      }
    }
  }

  var body: some View {
    GeometryReader { geometry in
      VStack {
        Spacer()
        HStack(alignment: .center, spacing: 12) {
          Group {
            Image(
              systemName:
                self.pinsState.isLoading
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
            self.pinsState.isLoading
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
          if !self.pinsState.isLoading && !isError {
            Button(action: self.handleComplete) {}
              .variant(.primary, size: .small, icon: Image(systemName: "checkmark"))
          }
        }
        .padding(12)
        .background(
          isError
          ? Color.piny.red10
          : Color.piny.level48
        )
        .overlay(
          RoundedRectangle(cornerRadius: 40, style: .continuous)
            .stroke(
              isError
              ? Color.piny.red
              : Color.clear,
              lineWidth: 2
            )
        )
        .cornerRadius(40)
        .shadow(
          color: isError
          ? .piny.red.opacity(0.5)
          : .piny.black.opacity(0.08),
          radius: isError ? 16 : 48
        )
      }
      .padding(.horizontal, 12)
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
