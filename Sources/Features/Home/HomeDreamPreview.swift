import SwiftUI

struct HomeDreamPreview: View {
  var latest: DreamEntry?
  var onOpen: () -> Void

  var body: some View {
    VStack(spacing: 20) {
      Text("Give your dream a shape.").font(.title2).fontDesign(.serif).padding(.top, 24)
      Button(action: onOpen) {
        Group {
          if let latest {
            DreamPortrait(entry: latest, pixels: 780, animates: false)
          } else {
            DreamPortraitPlaceholder()
          }
        }.frame(maxHeight: 470)
      }
      .buttonStyle(.plain).disabled(latest == nil)
      .accessibilityLabel(latest == nil ? "Visual exploration" : "Open your latest dream")
      Text(latest?.displayTitle ?? "What stayed with you?")
        .font(.body).foregroundStyle(Color("SecondaryInk")).lineLimit(2)
    }
  }
}
