//
//  WebView.swift
//  piny
//
//  Created by John Grishin on 15/07/2020.
//  Copyright © 2020 John Grishin. All rights reserved.
//

import SafariServices
import SwiftUI

struct WebView: View {
  var url: URL

  @Environment(\.dismiss) private var dismiss

  var body: some View {
    #if targetEnvironment(macCatalyst)
      NavigationStack {
        WebViewRepresentable(url: url)
          .toolbar {
            ToolbarItem(placement: .cancellationAction) {
              Button("Cancel", systemImage: "xmark") {
                dismiss()
              }
            }
          }
      }
    #else
      WebViewRepresentable(url: url)
    #endif
  }
}

private struct WebViewRepresentable: UIViewControllerRepresentable {
  var url: URL

  func makeUIViewController(
    context: UIViewControllerRepresentableContext<WebViewRepresentable>
  ) -> WebViewController {
    return WebViewController(url: url)
  }

  func updateUIViewController(
    _ safariViewController: WebViewController,
    context: UIViewControllerRepresentableContext<WebViewRepresentable>
  ) {
    safariViewController.update(url: url)
  }
}

#Preview {
  WebView(url: URL(string: "https://example.com")!)
}
