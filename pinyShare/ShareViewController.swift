//
//  ShareViewController.swift
//  pinyAdd
//
//  Created by John Grishin on 26/07/2020.
//  Copyright © 2020 John Grishin. All rights reserved.
//

import UIKit
import SwiftUI
import PromiseKit
import UniformTypeIdentifiers
import MobileCoreServices

fileprivate let HEIGHT: CGFloat = 58
fileprivate let WIDTH: CGFloat = 320

class ShareViewController: UIViewController {
  override func viewDidLoad() {
    super.viewDidLoad()

    clearView(view)
    modalPresentationStyle = .overCurrentContext

    firstly {
      self.getInput()
    }.done { page in
      self.render(page: page)
    }.catch { error in
      Piny.log(error, .error)
      self.complete()
    }
  }

  override func viewWillAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    makeContainersClear()
  }

  func render(page: ParsedPage) {
    let rootView = QuickAdd(page: page, onComplete: complete)
      .environmentObject(UserState())
      .environmentObject(PinsState([]))

    DispatchQueue.main.async { [weak self] in
      guard let self = self else { return }

      let host = UIHostingController(rootView: rootView)

      self.addChild(host)
      self.view.addSubview(host.view)
      self.clearView(host.view)
      host.view.translatesAutoresizingMaskIntoConstraints = false

      NSLayoutConstraint.activate([
        host.view.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 12),
        host.view.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -12),
        host.view.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
        host.view.heightAnchor.constraint(equalToConstant: HEIGHT)
      ])

      host.didMove(toParent: self)
    }
  }

  func complete() {
    extensionContext?.completeRequest(returningItems: [], completionHandler: nil)
  }

  func getInput() -> Promise<ParsedPage> {
    guard let inputItems = extensionContext?.inputItems as? [NSExtensionItem] else {
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
      loadItem(UTType.propertyList.identifier, in: provider)
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
      loadItem(UTType.url.identifier, in: provider)
    }.map { item in
      if let url = item as? URL {
        return ParsedPage(title: nil, url: url)
      } else {
        throw QuickAddError.invalidResult
      }
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
