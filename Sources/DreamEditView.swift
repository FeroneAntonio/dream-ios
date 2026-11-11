import SwiftUI

struct DreamEditView: View {
    @State private var entry: DreamEntry
    @State private var title: String
    var onSave: (DreamEntry) -> Void
    @Environment(DreamStore.self) private var store
    @Environment(\.dismiss) private var dismiss

    init(entry: DreamEntry, onSave: @escaping (DreamEntry) -> Void) {
        _entry = State(initialValue: entry)
        _title = State(initialValue: entry.title ?? "")
        self.onSave = onSave
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("The memory") {
                    TextField("A title, if you like", text: $title)
                    TextField("Your dream", text: $entry.text, axis: .vertical).lineLimit(5...12)
                }
                Section("The portrait") {
                    Picker("Feeling", selection: $entry.feeling) {
                        ForEach(DreamFeeling.allCases) { feeling in Text(feeling.label).tag(feeling) }
                    }
                    Slider(value: $entry.intensity).accessibilityLabel("Intensity")
                    Picker("Shape", selection: $entry.motif) {
                        Text("Orbits").tag(DreamMotif.orbit)
                        Text("Flow").tag(DreamMotif.flow)
                        Text("Fragments").tag(DreamMotif.fragment)
                    }
                }
                Section("Your reflection") {
                    TextField("What comes to mind?", text: $entry.reflection, axis: .vertical).lineLimit(3...8)
                }
                if let error = store.error { Text(error).foregroundStyle(.orange) }
            }
            .navigationTitle("Edit dream")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Cancel", action: cancel) }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save", action: save)
                        .disabled(entry.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && entry.audioFilename == nil)
                }
            }
        }
    }
    private func cancel() { dismiss() }
    private func save() {
        entry.title = title.trimmingCharacters(in: .whitespacesAndNewlines)
        if store.save(entry) { onSave(entry); dismiss() }
    }
}
