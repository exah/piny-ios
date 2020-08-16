//
//  TagsField.swift
//  piny
//
//  Created by John Grishin on 05/08/2020.
//  Copyright © 2020 John Grishin. All rights reserved.
//

import SwiftUI

struct TagsField: UIViewRepresentable {
  @Binding var tags: [PinTag]

  func makeUIView(context: Context) -> UISearchTextField {
    let uiView = UISearchTextField()

    uiView.placeholder = "Tags..."
    uiView.tokens = getTokens()
    uiView.clearButtonMode = .never
    uiView.autocorrectionType = .no
    uiView.autocapitalizationType = .none

    uiView.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
    uiView.leftViewMode = .never
    uiView.borderStyle = .roundedRect
    uiView.returnKeyType = .next

    uiView.delegate = context.coordinator

    return uiView
  }

  func updateUIView(_ uiView: UISearchTextField, context: Context) {
    uiView.tokens = getTokens()
  }

  func makeCoordinator() -> Coordinator {
    Coordinator(self)
  }

  func getTokens() -> [UISearchToken] {
    tags.map { tag in
      let token = UISearchToken(icon: nil, text: tag.name)
      token.representedObject = tag
      return token
    }
  }

  class Coordinator: NSObject, UISearchTextFieldDelegate {
    var parent: TagsField

    init(_ parent: TagsField) {
      self.parent = parent
    }

    func updateTags(_ textField: UITextField) {
      if let search = textField as? UISearchTextField {
        parent.tags = search.tokens.reduce([]) { acc, token in
          if let tag = token.representedObject as? PinTag {
            return acc + [tag]
          }

          return acc
        }
      }
    }

    var timer: Timer? = nil
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
      timer?.invalidate()
      timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: false) { _ in
        self.updateTags(textField)
      }

      return true
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
      if let text = textField.text?.trimmingCharacters(in: .whitespacesAndNewlines), text.count > 0 {
        if let search = textField as? UISearchTextField {
          let existingToken = search.tokens.first { token in
            if let tag = token.representedObject as? PinTag {
              return tag.name == text
            } else {
              return false
            }
          }

          if existingToken == nil {
            let tag = PinTag(id: UUID(), name: text)
            self.parent.tags.append(tag)
          }
        }

        textField.text = nil
      } else {
        textField.resignFirstResponder()
      }

      return false
    }
  }
}

struct TagsField_Previews: PreviewProvider {
  @State static var tags: [PinTag] = [
    PinTag(id: UUID(), name: "Hello"),
    PinTag(id: UUID(), name: "World")
  ]

  static var previews: some View {
    TagsField(tags: $tags)
  }
}
