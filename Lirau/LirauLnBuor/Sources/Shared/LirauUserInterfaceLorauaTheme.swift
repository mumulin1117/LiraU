import UIKit

enum LirauUserInterfaceLorauaTheme {
    static let interactiveLearningLorauaPrimary = UIColor(red: 0.72, green: 0.24, blue: 1.0, alpha: 1)
    static let interactiveLearningLorauaPrimaryEnd = UIColor(red: 0.93, green: 0.31, blue: 1.0, alpha: 1)
    static let visualCuesLorauaAccent = UIColor(red: 0.53, green: 0.23, blue: 1.0, alpha: 1)
    static let darkModeLorauaBackground = UIColor(red: 0.11, green: 0.10, blue: 0.18, alpha: 1)
    static let userExperienceLorauaCard = UIColor(red: 0.17, green: 0.15, blue: 0.26, alpha: 1)
    static let linguisticsLorauaText = UIColor.white
    static let languageAcquisitionLorauaSecondaryText = UIColor(white: 1.0, alpha: 0.64)
    static let verbalNuanceLorauaMutedText = UIColor(white: 1.0, alpha: 0.38)
    static let visualCuesLorauaBorder = UIColor(white: 1.0, alpha: 0.18)
    static let onboardingFlowLorauaAuthField = UIColor(red: 0.23, green: 0.20, blue: 0.31, alpha: 0.92)

    static func userInterfaceLorauaTitleFont(_ size: CGFloat = 28) -> UIFont {
        .systemFont(ofSize: size, weight: .bold)
    }

    static func readingComprehensionLorauaBodyFont(_ size: CGFloat = 16) -> UIFont {
        .systemFont(ofSize: size, weight: .regular)
    }

    static func interactiveLearningLorauaButtonFont() -> UIFont {
        .systemFont(ofSize: 16, weight: .semibold)
    }
}
