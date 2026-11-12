import Foundation

extension PaletteRecipe {
  /// Restricted print stocks and inks; these are artistic choices, not emotion codes.
  static func etching(seed: UInt64, dark: Bool) -> Self {
    if dark { return .make(.inkPaper, dark: true) }
    let stocks: [(UInt32, [UInt32])] = [
      (0xEEE8D9, [0x171E27, 0x5A5E62, 0xB9583F]),
      (0xF0EDE4, [0x26363B, 0x6F8080, 0xBF8642]),
      (0xEDE8E2, [0x302C40, 0x71667E, 0xA75655]),
      (0xEFE7D8, [0x342B27, 0x8A7560, 0xA55136]),
      (0xE8E9E3, [0x28372E, 0x77836C, 0xB09550]),
    ]
    var random = SeededRandom(seed: seed ^ 0xC010A)
    let stock = stocks[Int(random.next() % UInt64(stocks.count))]
    return Self(
      name: .inkPaper, background: VisualRGBA(stock.0), inks: stock.1.map { VisualRGBA($0) })
  }
}
