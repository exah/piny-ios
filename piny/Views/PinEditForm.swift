//
//  PinEditForm.swift
//  piny
//
//  Created by Claude Code on 12/12/2025.
//  Copyright © 2025 John Grishin. All rights reserved.
//

import SwiftUI

struct PinEditForm: View {
  @Environment(PinsState.self)
  var pinsState
  var pin: Pin

  @State
  var title: String = ""

  @State
  var description: String = ""

  @State
  var tags: [PinTag] = []

  @State
  var privacy: PinPrivacy = .private

  @State
  var showDeleteAlert: Bool = false

  var onClose: (() -> Void)? = nil

  func handleSave() {
    Task {
      do {
        try await pinsState.edit(
          pin,
          url: pin.link.url,
          title: title,
          description: description,
          privacy: privacy,
          tags: tags.map { $0.name }
        )
        onClose?()
      } catch {
        Piny.log(error, .error)
      }
    }
  }

  func handleDelete() {
    Task {
      do {
        try await pinsState.remove(pin)
        onClose?()
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

            Text(pin.link.url.absoluteString)
              .frame(maxWidth: .infinity, alignment: .leading)
              .textFieldVariant(.primary)
          }
          VStack(alignment: .leading, spacing: 0) {
            Text("Title")
              .textStyle(.secondary)
              .foregroundColor(.piny.grey65)
              .padding(.vertical, 10)

            TextField("", text: $title)
              .variant(.primary)
          }
          VStack(alignment: .leading, spacing: 0) {
            Text("Description")
              .textStyle(.secondary)
              .foregroundColor(.piny.grey65)
              .padding(.vertical, 10)

            TextEditor(text: $description)
              .variant(.primary, size: .textEditor)
              .scrollContentBackground(.hidden)
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
      .navigationBarTitleDisplayMode(.inline)
      .toolbar {
        ToolbarItem(placement: .principal) {
          Text("Edit")
            .textStyle(.h3)
        }
        ToolbarItem(placement: .cancellationAction) {
          Button("Cancel", systemImage: "xmark") {
            onClose?()
          }
        }
        ToolbarItem(placement: .confirmationAction) {
          Button("Save", systemImage: "checkmark", action: handleSave)
            .disabled(pinsState.result.edit.isLoading)
        }
      }
      .alert("Are you sure you want to delete this pin?", isPresented: $showDeleteAlert) {
        Button("Cancel", role: .cancel) {}
        Button("Delete", role: .destructive, action: handleDelete)
      }
    }
  }
}

// Preview
#Preview {
  let sampleTags = [
    PinTag(id: UUID(), name: "design"),
    PinTag(id: UUID(), name: "dev"),
    PinTag(id: UUID(), name: "education"),
    PinTag(id: UUID(), name: "programming"),
  ]
  let pin = PreviewContent.pins[0]

  PinEditForm(
    pin: pin,
    title: "Teach Yourself Computer Science",
    description: "",
    tags: [sampleTags[0], sampleTags[1]],
    privacy: .private
  )
  .environment(PinsState(PreviewContent.pins))
}
