//
//  WebView.swift
//  piny
//
//  Created by John Grishin on 15/07/2020.
//  Copyright © 2020 John Grishin. All rights reserved.
//

import SwiftUI
import SafariServices

struct WebView: UIViewControllerRepresentable {
  var url: URL
  
  typealias UIViewControllerType = WebViewController

  func makeUIViewController(context: UIViewControllerRepresentableContext<WebView>) -> WebViewController {
    return WebViewController(url: url)
  }

  func updateUIViewController(_ safariViewController: WebViewController, context: UIViewControllerRepresentableContext<WebView>) {
    safariViewController.destroy()
    safariViewController.update(url: url)
  }
}

struct WebView_Previews: PreviewProvider {
  static var previews: some View {
    WebView(url: URL(string: "https://example.com")!)
  }
}
