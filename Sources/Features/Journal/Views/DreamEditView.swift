import SwiftUI

struct DreamEditView: View {
  @State private var entry: DreamEntry
  @State private var title: String
  private let originalText: String
  private let originalReflection: String
  var onSave: (DreamEntry) -> Void
  @Environment(DreamStore.self) private var store
  @Environment(\.dismiss) private var dismiss

  init(entry: DreamEntry, onSave: @escaping (DreamEntry) -> Void) {
    _entry = State(initialValue: entry)
    _title = State(initialValue: entry.title ?? "")
    originalText = entry.text
    originalReflection = entry.reflection
    self.onSave = onSave
  }

  var body: some View {
    NavigationStack {
      Form {
        Section("The memory") {
          TextField("A title, if you like", text: $title)
          TextField("Your dream", text: $entry.text, axis: .vertical).lineLimit(5...12)
        }
        Section("Your feeling") {
          Picker("Feeling", selection: $entry.feeling) {
            ForEach(DreamFeeling.allCases) { feeling in Text(feeling.label).tag(feeling) }
          }
          Text("Your saved portrait stays the same. Use Refine portrait to change its appearance.")
            .font(.footnote)
        }
        Section("Your reflection") {
          TextField("What comes to mind?", text: $entry.reflection, axis: .vertical).lineLimit(
            3...8)
        }
        if let error = store.error { Text(error).foregroundStyle(.orange) }
      }
      .navigationTitle("Edit dream")
      .toolbar {
        ToolbarItem(placement: .cancellationAction) { Button("Cancel", action: cancel) }
        ToolbarItem(placement: .confirmationAction) {
          Button("Save", action: save)
            .disabled(
              entry.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                && entry.audioFilename == nil)
        }
      }
    }
  }
  private func cancel() { dismiss() }
  private func save() {
    entry.title = title.trimmingCharacters(in: .whitespacesAndNewlines)
    if entry.text != originalText {
      // Derived suggestions must never silently refer to an older story.
      entry.emotions = nil
      if entry.reflection == originalReflection && entry.usedAI {
        entry.reflection = ""
        entry.question = ""
      }
      entry.usedAI = false
    }
    if store.save(entry) {
      onSave(entry)
      dismiss()
    }
  }
}
