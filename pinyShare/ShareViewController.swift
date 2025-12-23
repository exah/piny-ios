//
//  ShareViewController.swift
//  pinyAdd
//
//  Created by John Grishin on 26/07/2020.
//  Copyright © 2020 John Grishin. All rights reserved.
//

import MobileCoreServices
import SwiftData
import SwiftUI
import UIKit
import UniformTypeIdentifiers

private let HEIGHT: CGFloat = 58
private let WIDTH: CGFloat = 320

class ShareViewController: UIViewController {
  override func viewDidLoad() {
    super.viewDidLoad()

    clearView(view)
    modalPresentationStyle = .overCurrentContext

    Task {
      do {
        let page = try await getInput()
        render(page: page)
      } catch {
        Piny.log(error, .error)
        complete()
      }
    }
  }

  override func viewWillAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    makeContainersClear()
  }

  func render(page: ParsedPage) {
    let rootView = QuickAdd(
      page: page,
      onComplete: complete
    )
    .modelContainer(Piny.storage.container)
    .environment(AsyncUser())
    .environment(AsyncPins())
    .environment(AsyncTags())

    DispatchQueue.main.async { [weak self] in
      guard let self = self else { return }

      let host = UIHostingController(rootView: rootView)

      self.addChild(host)
      self.view.addSubview(host.view)
      self.clearView(host.view)
      host.view.translatesAutoresizingMaskIntoConstraints = false

      NSLayoutConstraint.activate([
        host.view.leadingAnchor.constraint(
          equalTo: view.leadingAnchor,
          constant: 12
        ),
        host.view.trailingAnchor.constraint(
          equalTo: view.trailingAnchor,
          constant: -12
        ),
        host.view.bottomAnchor.constraint(
          equalTo: view.safeAreaLayoutGuide.bottomAnchor
        ),
        host.view.heightAnchor.constraint(equalToConstant: HEIGHT),
      ])

      host.didMove(toParent: self)
    }
  }

  func complete() {
    extensionContext?
      .completeRequest(returningItems: [], completionHandler: nil)
  }

  func getInput() async throws -> ParsedPage {
    guard let inputItems = extensionContext?.inputItems as? [NSExtensionItem]
    else {
      throw QuickAddError.invalidInput
    }

    let providers = inputItems.compactMap { $0.attachments }.joined()

    return try await withThrowingTaskGroup(of: ParsedPage.self) { group in
      for provider in providers {
        group.addTask {
          do {
            return try await self.getPage(provider)
          } catch QuickAddError.pageParseFailed {
            return try await self.getURL(provider)
          } catch {
            throw error
          }
        }
      }

      guard let result = try await group.next() else {
        throw QuickAddError.noAttachments
      }

      group.cancelAll()
      return result
    }
  }

  private func loadItem(
    _ identifier: String,
    in provider: NSItemProvider
  ) async throws -> NSSecureCoding? {
    guard provider.hasItemConformingToTypeIdentifier(identifier) else {
      throw QuickAddError.noResult
    }

    return try await withCheckedThrowingContinuation { continuation in
      provider.loadItem(forTypeIdentifier: identifier) { item, error in
        if let error = error {
          continuation.resume(throwing: error)
        } else {
          continuation.resume(returning: item)
        }
      }
    }
  }

  private func getPage(_ provider: NSItemProvider) async throws -> ParsedPage {
    let item = try await loadItem(UTType.propertyList.identifier, in: provider)

    if let dict = item as? NSDictionary,
      let data = dict[NSExtensionJavaScriptPreprocessingResultsKey]
        as? [String: String],
      let pageURL = URL(string: data["url"]!)
    {
      return ParsedPage(title: data["title"], url: pageURL)
    } else {
      throw QuickAddError.pageParseFailed
    }
  }

  private func getURL(_ provider: NSItemProvider) async throws -> ParsedPage {
    let item = try await loadItem(UTType.url.identifier, in: provider)

    if let url = item as? URL {
      return ParsedPage(title: nil, url: url)
    } else {
      throw QuickAddError.invalidResult
    }
  }

  private func clearView(_ view: UIView?) {
    view?.isOpaque = false
    view?.backgroundColor = .clear
  }

  private func makeContainersClear() {
    var view: UIView? = self.view
    while let superview = view?.superview {
      clearView(superview)
      view = superview
    }

    clearView(self.view.window)
  }
}
