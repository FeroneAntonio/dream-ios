import SwiftUI

struct NotebookPaper: View {
  var body: some View {
    Canvas { context, size in
      context.fill(
        Path(CGRect(origin: .zero, size: size)),
        with: .color(Color(red: 0.95, green: 0.92, blue: 0.85)))
      let margin = CGRect(x: 12, y: 0, width: 1, height: size.height)
      context.fill(Path(margin), with: .color(.brown.opacity(0.16)))
      for index in 0..<1800 {
        let n = Double(index)
        let x = (sin(n * 127.1) * 43758.54).truncatingRemainder(dividingBy: 1)
        let y = (sin(n * 311.7) * 13758.54).truncatingRemainder(dividingBy: 1)
        let dot = CGRect(x: abs(x) * size.width, y: abs(y) * size.height, width: 0.7, height: 0.7)
        context.fill(Path(ellipseIn: dot), with: .color(.brown.opacity(0.12)))
      }
    }
    .accessibilityHidden(true)
  }
}
