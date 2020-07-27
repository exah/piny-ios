//
//  QuickAdd.swift
//  pinyAdd
//
//  Created by John Grishin on 26/07/2020.
//  Copyright © 2020 John Grishin. All rights reserved.
//

import SwiftUI
import MobileCoreServices

private enum QuickAddError: Error {
  case invalidInput
  case invalidURL
  case noAttachments
  case noResult
}

struct QuickAdd: View {
  @EnvironmentObject var userState: UserState
  @EnvironmentObject var pinsState: PinsState

  let context: NSExtensionContext
  let timeout: Double = 2

  func handleAppear() {
    getUrl() { url in
      switch url {
        case .success(let url):
          if let user = self.userState.user {
            self.pinsState.create(
              for: user,
              url: url,
              privacy: .Public
            ) { result in
              switch result {
                case .success:
                  log("Shared: \(url) <3")

                  DispatchQueue.main.asyncAfter(deadline: .now() + self.timeout) {
                    self.handleComplete()
                  }
                case .failure(let error):
                  log(error, level: .error)
              }
            }
          }
        case .failure(let error):
          log(error, level: .error)
      }
    }
  }

  func handleComplete() {
    self.context.completeRequest(returningItems: nil) { _ in
      log("Done")
    }
  }

  func handleAction() {
    log("Action")
  }

  func getUrl(onComplete: @escaping (_ result: Result<URL, Error>) -> Void) {
    guard let inputItems = context.inputItems as? [NSExtensionItem] else {
      onComplete(.failure(QuickAddError.invalidInput))
      return
    }

    for item in inputItems {
      guard let attachments = item.attachments else {
        onComplete(.failure(QuickAddError.noAttachments))
        return
      }

      for provider in attachments {
        if provider.hasItemConformingToTypeIdentifier(kUTTypeURL as String) {
          provider.loadItem(
            forTypeIdentifier: kUTTypeURL as String,
            options: nil
          ) { url, error in
            if let error = error {
              onComplete(.failure(error))
              return
            }

            OperationQueue.main.addOperation {
              if let url = url as? URL {
                onComplete(.success(url))
              } else {
                onComplete(.failure(QuickAddError.invalidURL))
              }
            }
          }

          return
        }
      }
    }

    onComplete(.failure(QuickAddError.noResult))
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
                : "checkmark.circle.fill"
          )
            .resizable()
            .aspectRatio(contentMode: .fit)
            .foregroundColor(
              self.pinsState.isLoading
                ? .orange
                : .green
            )
            .frame(width: 24)
          Text(
            self.pinsState.isLoading
              ? "Adding..."
              : "Added to Piny"
          )
            .font(.system(size: 18))
            .fontWeight(.semibold)
            .foregroundColor(.black)
          Spacer()
          if !self.pinsState.isLoading {
            Button(action: self.handleAction) {
              Text("Action")
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
      .environmentObject(PinsState())
      .previewLayout(PreviewLayout.sizeThatFits)
      .background(Color.gray)
  }
}
