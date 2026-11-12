import Foundation

struct PaletteRecipe: Codable, Hashable, Sendable {
  var name: VisualPalette
  var background: VisualRGBA
  var inks: [VisualRGBA]
  static func make(_ palette: VisualPalette, dark: Bool = false) -> Self {
    let paper = VisualRGBA(0xEEE8D9)
    let carbon = VisualRGBA(0x191A24)
    let colors: [VisualRGBA]
    switch palette {
    case .inkPaper: colors = [carbon, VisualRGBA(0x625E5D), VisualRGBA(0xC04E39)]
    case .acidDream:
      colors = [
        VisualRGBA(0xF34875), VisualRGBA(0xF39847), VisualRGBA(0x8F60D6), VisualRGBA(0xE7E65B),
      ]
    case .chromaticHaze:
      colors = [
        VisualRGBA(0xD44768), VisualRGBA(0xEE9D4E), VisualRGBA(0x7658AE), VisualRGBA(0x50A7A5),
      ]
    case .nightPrint:
      colors = [VisualRGBA(0x293C91), VisualRGBA(0xC14D42), VisualRGBA(0x928BD0), paper]
    case .mutedMemory:
      colors = [VisualRGBA(0x567D71), VisualRGBA(0xB76D51), VisualRGBA(0x9993B7), carbon]
    }
    if dark {
      let lightColors =
        palette == .inkPaper ? [paper, VisualRGBA(0xA9A39A), VisualRGBA(0xC68A52)] : colors
      return Self(name: palette, background: VisualRGBA(0x151725), inks: lightColors)
    }
    return Self(name: palette, background: paper, inks: colors)
  }
  var isValid: Bool {
    background.isValid && (2...6).contains(inks.count) && inks.allSatisfy(\.isValid)
  }
}
