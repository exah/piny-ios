//
//  WebViewController.swift
//  piny
//
//  Created by John Grishin on 16/07/2020.
//  Copyright © 2020 John Grishin. All rights reserved.
//

import SafariServices
import SwiftUI
import WebKit

final class WebViewController: UIViewController {
  private var url: URL?

  #if targetEnvironment(macCatalyst)
    private var webView: WKWebView?
  #elseif os(iOS)
    private var controller: SFSafariViewController?
  #endif

  init(url: URL) {
    self.url = url
    super.init(nibName: nil, bundle: nil)
  }

  required init?(coder: NSCoder) {
    self.url = nil
    super.init(coder: coder)
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    update(url: url!)
  }

  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    #if targetEnvironment(macCatalyst)
      webView?.frame = view.bounds
    #elseif os(iOS)
      controller?.view.frame = view.frame
    #endif
  }

  func update(url nextUrl: URL) {
    if url == nextUrl {
      #if targetEnvironment(macCatalyst)
        if webView != nil { return }
      #elseif os(iOS)
        if controller != nil { return }
      #endif
    } else {
      destroy()
    }

    #if targetEnvironment(macCatalyst)
      let configuration = WKWebViewConfiguration()
      let nextWebView = WKWebView(frame: view.bounds, configuration: configuration)
      nextWebView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
      nextWebView.allowsBackForwardNavigationGestures = true
      nextWebView.load(URLRequest(url: nextUrl))
      view.addSubview(nextWebView)
      webView = nextWebView
    #elseif os(iOS)
      let nextController = SFSafariViewController(url: nextUrl)
      addChild(nextController)
      view.addSubview(nextController.view)
      nextController.didMove(toParent: self)
      controller = nextController
    #endif

    url = nextUrl
  }

  func destroy() {
    #if targetEnvironment(macCatalyst)
      webView?.removeFromSuperview()
      webView = nil
    #elseif os(iOS)
      guard let prevController = controller else {
        return
      }
      prevController.willMove(toParent: nil)
      prevController.view.removeFromSuperview()
      prevController.removeFromParent()
      controller = nil
    #endif
  }
}
