import SwiftUI

struct DreamRow: View {
  var entry: DreamEntry
  var body: some View {
    HStack(spacing: 16) {
      DreamPortrait(entry: entry, pixels: 176, animates: false)
        .frame(width: 88, height: 88).accessibilityHidden(true)
      VStack(alignment: .leading, spacing: 6) {
        Text(entry.date, format: .dateTime.day().month(.wide)).font(.footnote).foregroundStyle(
          Color("SecondaryInk"))
        Text(entry.displayTitle).lineLimit(2).fontDesign(.serif)
        Text(entry.feeling.label).font(.footnote)
      }
      Spacer(minLength: 0)
      Image(systemName: "chevron.right").accessibilityHidden(true)
    }
    .frame(minHeight: 64)
  }
}
