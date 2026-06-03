import Foundation

struct LirauUserProfile: Codable, Equatable {
    let userID: String
    let token: String
    let email: String
    var displayName: String
    var profileIntroLoraua: String
    var languagePairingLoraua: String

    static let testProfile = LirauUserProfile(
        userID: "lirau_test_user",
        token: "lirau_local_token_454545",
        email: "lariau@gmail.com",
        displayName: "LiraU Speaker",
        profileIntroLoraua: "Practicing Spanish jokes and sharing everyday culture.",
        languagePairingLoraua: "English - Spanish"
    )
}
