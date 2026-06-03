import UIKit

enum LirauTheme {
    static let primary = UIColor(red: 0.72, green: 0.24, blue: 1.0, alpha: 1)
    static let primaryEnd = UIColor(red: 0.93, green: 0.31, blue: 1.0, alpha: 1)
    static let accent = UIColor(red: 0.53, green: 0.23, blue: 1.0, alpha: 1)
    static let background = UIColor(red: 0.11, green: 0.10, blue: 0.18, alpha: 1)
    static let card = UIColor(red: 0.17, green: 0.15, blue: 0.26, alpha: 1)
    static let text = UIColor.white
    static let secondaryText = UIColor(white: 1.0, alpha: 0.64)
    static let mutedText = UIColor(white: 1.0, alpha: 0.38)
    static let border = UIColor(white: 1.0, alpha: 0.18)
    static let authField = UIColor(red: 0.23, green: 0.20, blue: 0.31, alpha: 0.92)

    static func titleFont(_ size: CGFloat = 28) -> UIFont {
        .systemFont(ofSize: size, weight: .bold)
    }

    static func bodyFont(_ size: CGFloat = 16) -> UIFont {
        .systemFont(ofSize: size, weight: .regular)
    }

    static func buttonFont() -> UIFont {
        .systemFont(ofSize: 16, weight: .semibold)
    }
}
