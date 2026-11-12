import SwiftUI

struct DreamJournal: View {
  var onNewPage: () -> Void
  @Environment(DreamStore.self) private var store
  @Environment(\.dismiss) private var dismiss
  @State private var selected: UUID?

  var body: some View {
    NavigationStack {
      VStack(spacing: 8) {
        Text("My dream journal")
          .font(.custom("Noteworthy-Light", size: 27, relativeTo: .title))
          .padding(.top)
        if store.entries.isEmpty {
          NotebookEmpty(action: compose)
        } else {
          TabView(selection: $selected) {
            ForEach(store.entries) { entry in
              NotebookPage(entry: entry).tag(Optional(entry.id))
            }
          }
          .tabViewStyle(.page(indexDisplayMode: .never))
          HStack {
            Text(pageLabel)
            Spacer()
            Label("Swipe to turn the page", systemImage: "arrow.left.and.right")
          }
          .font(.footnote).foregroundStyle(Color("SecondaryInk"))
          .padding(.horizontal, 28).padding(.bottom, 12)
        }
      }
      .background(Color(red: 0.09, green: 0.085, blue: 0.08))
      .toolbar {
        ToolbarItem(placement: .cancellationAction) {
          Button("Chiudi", systemImage: "xmark", action: close)
        }
        ToolbarItem(placement: .primaryAction) {
          Button("New page", systemImage: "plus", action: compose)
        }
      }
      .navigationDestination(for: UUID.self) { id in
        if let entry = store.entries.first(where: { $0.id == id }) { DreamDetail(entry: entry) }
      }
      .onChange(of: store.entries.count, selectFirst)
      .task { selectFirst() }
    }
  }

  private var pageLabel: String {
    guard let selected, let index = store.entries.firstIndex(where: { $0.id == selected }) else {
      return ""
    }
    return "\(index + 1) of \(store.entries.count)"
  }
  private func selectFirst() {
    if selected == nil || !store.entries.contains(where: { $0.id == selected }) {
      selected = store.entries.first?.id
    }
  }
  private func compose() { onNewPage() }
  private func close() { dismiss() }
}
