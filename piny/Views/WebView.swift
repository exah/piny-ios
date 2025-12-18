//
//  WebView.swift
//  piny
//
//  Created by John Grishin on 15/07/2020.
//  Copyright © 2020 John Grishin. All rights reserved.
//

import SafariServices
import SwiftUI

struct WebView: UIViewControllerRepresentable {
  var url: URL

  func makeUIViewController(
    context: UIViewControllerRepresentableContext<WebView>
  ) -> WebViewController {
    return WebViewController(url: url)
  }

  func updateUIViewController(
    _ safariViewController: WebViewController,
    context: UIViewControllerRepresentableContext<WebView>
  ) {
    safariViewController.update(url: url)
  }
}

#Preview {
  WebView(url: URL(string: "https://example.com")!)
}
