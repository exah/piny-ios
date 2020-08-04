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
        privacy: .PUBLIC
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
    .finally {
      DispatchQueue.main.asyncAfter(deadline: .now() + self.timeout) {
        self.handleComplete()
      }
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
