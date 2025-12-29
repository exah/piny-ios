//
//  PinEditForm.swift
//  piny
//
//  Created by Claude Code on 12/12/2025.
//  Copyright © 2025 John Grishin. All rights reserved.
//

import SwiftUI

private class Errors: ObservableObject {
  @Published
  var url: String? = nil
}

private enum Field: Int, Hashable {
  case url, title, description
}

struct PinEditForm: View {
  @Environment(PinState.self)
  var pinState
  var pin: PinModel

  @StateObject
  private var errors = Errors()

  @FocusState
  private var focused: Field?

  @State
  var url: String = ""

  @State
  var title: String = ""

  @State
  var description: String = ""

  @State
  var tags: [TagModel] = []

  @State
  var privacy: PinPrivacy = .private

  @State
  var showDeleteAlert: Bool = false

  var onClose: () -> Void

  func validate() -> (
    url: URL,
    title: String,
    description: String,
    privacy: PinPrivacy,
    tags: [String]
  )? {
    guard
      let url = URL(string: url.trimmingCharacters(in: .whitespaces)),
      UIApplication.shared.canOpenURL(url)
    else {
      errors.url = "Invalid format"
      return nil
    }

    errors.url = nil

    return (
      url: url,
      title: title,
      description: description,
      privacy: privacy,
      tags: tags.map { $0.name }
    )
  }

  func handleSave() {
    Task {
      do {
        guard let validated = validate() else {
          return
        }

        try await pinState.edit(
          pin,
          url: validated.url,
          title: validated.title,
          description: validated.description,
          privacy: validated.privacy,
          tags: validated.tags
        )

        onClose()
      } catch {
        Piny.log("Failed to save: \(error)", .error)
      }
    }
  }

  func handleDelete() {
    Task {
      do {
        try await pinState.delete(pin)
        onClose()
      } catch {
        Piny.log(error, .error)
      }
    }
  }

  var body: some View {
    NavigationView {
      ScrollView {
        VStack(alignment: .leading, spacing: 4) {
          VStack(alignment: .leading, spacing: 0) {
            Text("URL")
              .textStyle(.secondary)
              .foregroundColor(.piny.grey65)
              .padding(.vertical, 10)

            Input(
              value: Binding(
                get: { url },
                set: { value in
                  if value.lastIndex(of: "\n") != nil {
                    focused = nil
                  } else {
                    url = value
                  }
                }
              ),
              axis: .vertical,
              invalid: errors.url != nil,
              message: errors.url
            )
            .focused($focused, equals: .url)
            .keyboardType(.URL)
            .submitLabel(.done)
          }
          VStack(alignment: .leading, spacing: 0) {
            Text("Title")
              .textStyle(.secondary)
              .foregroundColor(.piny.grey65)
              .padding(.vertical, 10)

            Input(
              value: Binding(
                get: { title },
                set: { value in
                  if value.lastIndex(of: "\n") != nil {
                    focused = nil
                  } else {
                    title = value
                  }
                }
              ),
              axis: .vertical
            )
            .focused($focused, equals: .title)
            .submitLabel(.done)
          }
          VStack(alignment: .leading, spacing: 0) {
            Text("Description")
              .textStyle(.secondary)
              .foregroundColor(.piny.grey65)
              .padding(.vertical, 10)

            Input(value: $description, type: .editor)
              .focused($focused, equals: .description)
          }
          VStack(alignment: .leading, spacing: 0) {
            Text("Tags")
              .textStyle(.secondary)
              .foregroundColor(.piny.grey65)
              .padding(.vertical, 10)

            PinTagsInput(tags: $tags)
          }
          VStack(alignment: .leading, spacing: 0) {
            Text("Private")
              .textStyle(.secondary)
              .foregroundColor(.piny.grey65)
              .padding(.vertical, 10)

            Toggle(
              "",
              isOn: Binding(
                get: { privacy == .private },
                set: { privacy = $0 ? .private : .public }
              )
            )
            .labelsHidden()
            .tint(.piny.blue)
          }
          Spacer()
            .padding(.bottom, 24)
          Button("Delete") {
            showDeleteAlert = true
          }
          .variant(.destructive, size: .medium)
          .frame(maxWidth: .infinity)
        }
        .padding(24)
      }
      .scrollDismissesKeyboard(.immediately)
      .navigationBarTitleDisplayMode(.inline)
      .toolbar {
        ToolbarItem(placement: .principal) {
          Text("Edit")
            .textStyle(.h3)
        }
        ToolbarItem(placement: .cancellationAction) {
          Button("Cancel", systemImage: "xmark", action: onClose)
        }
        ToolbarItem(placement: .confirmationAction) {
          Button("Save", systemImage: "checkmark", action: handleSave)
            .disabled(pinState.result.edit.isLoading)
        }
      }
      .alert("Are you sure you want to delete this pin?", isPresented: $showDeleteAlert) {
        Button("Cancel", role: .cancel) {}
        Button("Delete", role: .destructive, action: handleDelete)
      }
    }
  }
}

#Preview {
  let sampleTags = [
    TagModel(id: UUID(), name: "design"),
    TagModel(id: UUID(), name: "dev"),
    TagModel(id: UUID(), name: "education"),
    TagModel(id: UUID(), name: "programming"),
  ]
  let pin = PreviewContent.pins[0]

  PinEditForm(
    pin: pin,
    url: pin.link.url.absoluteString,
    title: "Teach Yourself Computer Science",
    description: "",
    tags: [sampleTags[0], sampleTags[1]],
    privacy: .private,
    onClose: {}
  )
  .environment(PinState(PreviewContent.pins))
}
