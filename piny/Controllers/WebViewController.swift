//
//  WebViewController.swift
//  piny
//
//  Created by John Grishin on 16/07/2020.
//  Copyright © 2020 John Grishin. All rights reserved.
//

import SwiftUI
import SafariServices

final class WebViewController: UIViewController {
  private var url: URL?
  private var controller: SFSafariViewController?

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
    controller?.view.frame = view.frame
  }

  func update(url nextUrl: URL) {
    if url == nextUrl && controller != nil {
      return
    } else {
      destroy()
    }

    let nextController = SFSafariViewController(url: nextUrl)

    addChild(nextController)
    view.addSubview(nextController.view)
    nextController.didMove(toParent: self)

    controller = nextController
    url = nextUrl
  }
  
  func destroy() {
    guard let prevController = controller else {
      return
    }

    prevController.willMove(toParent: nil)
    prevController.view.removeFromSuperview()
    prevController.removeFromParent()

    controller = nil
  }
}
