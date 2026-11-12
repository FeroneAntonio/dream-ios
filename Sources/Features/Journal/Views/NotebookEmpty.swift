import SwiftUI

struct NotebookEmpty: View {
  var action: () -> Void

  var body: some View {
    VStack(alignment: .leading, spacing: 28) {
      Text("This journal\nbelongs to my dreams.")
        .font(.custom("Noteworthy-Light", size: 30, relativeTo: .largeTitle))
      Spacer()
      DreamcatcherMark().frame(width: 64, height: 90).accessibilityHidden(true)
      Text("For the strange things,\nthe beautiful ones,\nthe ones I don’t want to forget.")
        .font(.custom("Noteworthy-Light", size: 21, relativeTo: .body)).lineSpacing(8)
      Spacer()
      Button("The first page", systemImage: "pencil", action: action)
        .buttonStyle(.bordered).tint(Color(red: 0.24, green: 0.22, blue: 0.20))
        .controlSize(.large)
    }
    .foregroundStyle(Color(red: 0.17, green: 0.18, blue: 0.21))
    .padding(32).frame(maxWidth: 620, maxHeight: .infinity, alignment: .leading)
    .background { NotebookPaper() }
    .clipShape(.rect(cornerRadius: 3)).padding(20)
    .environment(\.colorScheme, .light)
  }
}
