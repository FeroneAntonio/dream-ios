import SwiftUI

struct DreamNightSection: View {
  var night: NightContext?
  var isLoading: Bool
  var message: String
  var onLoad: () -> Void

  var body: some View {
    DisclosureGroup("The night") {
      VStack(alignment: .leading, spacing: 16) {
        if let night {
          NightSummary(night: night)
        } else {
          Button("Add sleep data", systemImage: "heart", action: onLoad)
            .frame(minHeight: 44).disabled(isLoading)
        }
        if isLoading { ProgressView() }
        Text(message).font(.footnote).foregroundStyle(Color("SecondaryInk"))
      }.padding(.top)
    }
  }
}
