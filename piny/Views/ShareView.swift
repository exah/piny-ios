//
//  ShareView.swift
//  piny
//
//  Created by J. Grishin on 22/08/2025.
//  Copyright © 2025 John Grishin. All rights reserved.
//

import SafariServices
import SwiftUI

struct ShareView: UIViewControllerRepresentable {
  var url: URL

  func makeUIViewController(
    context: UIViewControllerRepresentableContext<ShareView>
  ) -> UIActivityViewController {
    return UIActivityViewController(
      activityItems: [url],
      applicationActivities: nil
    )
  }

  func updateUIViewController(
    _ uiViewController: UIActivityViewController,
    context: Context
  ) {
    // Ignore
  }
}

#Preview {
  ShareView(url: URL(string: "https://example.com")!)
}
