import Foundation

struct LirauUserProfile: Codable, Equatable {
    let userID: String
    let Token: String
    let email: String
    var displayName: String
    var profileIntroLoraua: String
    var languagePairingLoraua: String

    static let testProfile = LirauUserProfile(
        userID: "lirau_test_user",
        Token: "lirau_local_token_454545",
        email: "lariau@gmail.com",
        displayName: "LiraU Speaker",
        profileIntroLoraua: "Practicing Spanish jokes and sharing everyday culture.",
        languagePairingLoraua: "English - Spanish"
    )

    func mergingRemoteProfile(_ remote: LirauUserProfile, fallbackPassword: String) -> LirauUserProfile {
        LirauUserProfile(
            userID: remote.userID.isEmpty ? userID : remote.userID,
            Token: remote.Token.isEmpty ? fallbackPassword : remote.Token,
            email: remote.email.isEmpty ? email : remote.email,
            displayName: remote.displayName.isEmpty ? displayName : remote.displayName,
            profileIntroLoraua: remote.profileIntroLoraua.isEmpty ? profileIntroLoraua : remote.profileIntroLoraua,
            languagePairingLoraua: languagePairingLoraua
        )
    }
}
