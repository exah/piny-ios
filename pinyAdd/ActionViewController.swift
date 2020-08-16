//
//  ActionViewController.swift
//  pinyAdd
//
//  Created by John Grishin on 26/07/2020.
//  Copyright © 2020 John Grishin. All rights reserved.
//

import UIKit
import SwiftUI
import MobileCoreServices

class ActionViewController: UIViewController {
  @IBSegueAction func connectSwiftUI(_ coder: NSCoder) -> UIViewController? {
    guard let context = self.extensionContext else {
      Piny.log("Extention context is required", .error)
      return nil
    }

    let controller = UIHostingController(
      coder: coder,
      rootView: QuickAdd(context: context)
        .environmentObject(UserState())
        .environmentObject(PinsState([]))
    )

    controller?.view.backgroundColor = .clear

    return controller
  }
}
