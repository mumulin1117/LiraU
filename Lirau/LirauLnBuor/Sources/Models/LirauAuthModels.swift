import Foundation

struct LirauGlobalCitizenLorauaAccountProfile: Equatable {
    let globalCitizenLorauaID: String
    let pointSystemLorauaToken: String
    let emailMarketingLorauaAddress: String
    var nativeSpeakerLorauaName: String
    var profileIntroLorauaBio: String
    var languagePairingLorauaSummary: String

    static let globalCitizenLorauaTestProfile = LirauGlobalCitizenLorauaAccountProfile(
        globalCitizenLorauaID: "lirau_test_user",
        pointSystemLorauaToken: "lirau_local_token_454545",
        emailMarketingLorauaAddress: "lariau@gmail.com",
        nativeSpeakerLorauaName: "LiraU Speaker",
        profileIntroLorauaBio: "Practicing Spanish jokes and sharing everyday culture.",
        languagePairingLorauaSummary: "English - Spanish"
    )

    func mergingRemoteGlobalCitizenLorauaProfile(_ remote: LirauGlobalCitizenLorauaAccountProfile, fallbackPassword: String) -> LirauGlobalCitizenLorauaAccountProfile {
        LirauGlobalCitizenLorauaAccountProfile(
            globalCitizenLorauaID: remote.globalCitizenLorauaID.isEmpty ? globalCitizenLorauaID : remote.globalCitizenLorauaID,
            pointSystemLorauaToken: remote.pointSystemLorauaToken.isEmpty ? fallbackPassword : remote.pointSystemLorauaToken,
            emailMarketingLorauaAddress: remote.emailMarketingLorauaAddress.isEmpty ? emailMarketingLorauaAddress : remote.emailMarketingLorauaAddress,
            nativeSpeakerLorauaName: remote.nativeSpeakerLorauaName.isEmpty ? nativeSpeakerLorauaName : remote.nativeSpeakerLorauaName,
            profileIntroLorauaBio: remote.profileIntroLorauaBio.isEmpty ? profileIntroLorauaBio : remote.profileIntroLorauaBio,
            languagePairingLorauaSummary: languagePairingLorauaSummary
        )
    }
}

extension LirauGlobalCitizenLorauaAccountProfile: Codable {
    enum CodingKeys: String, CodingKey {
        case globalCitizenLorauaID
        case pointSystemLorauaToken
        case emailMarketingLorauaAddress
        case nativeSpeakerLorauaName
        case profileIntroLorauaBio
        case languagePairingLorauaSummary
        case userID
        case Token
        case email
        case displayName
        case profileIntroLoraua
        case languagePairingLoraua
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.init(
            globalCitizenLorauaID: try container.decodeCompatibleString(primary: .globalCitizenLorauaID, legacy: .userID),
            pointSystemLorauaToken: try container.decodeCompatibleString(primary: .pointSystemLorauaToken, legacy: .Token),
            emailMarketingLorauaAddress: try container.decodeCompatibleString(primary: .emailMarketingLorauaAddress, legacy: .email),
            nativeSpeakerLorauaName: try container.decodeCompatibleString(primary: .nativeSpeakerLorauaName, legacy: .displayName),
            profileIntroLorauaBio: try container.decodeCompatibleString(primary: .profileIntroLorauaBio, legacy: .profileIntroLoraua),
            languagePairingLorauaSummary: try container.decodeCompatibleString(primary: .languagePairingLorauaSummary, legacy: .languagePairingLoraua)
        )
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(globalCitizenLorauaID, forKey: .globalCitizenLorauaID)
        try container.encode(pointSystemLorauaToken, forKey: .pointSystemLorauaToken)
        try container.encode(emailMarketingLorauaAddress, forKey: .emailMarketingLorauaAddress)
        try container.encode(nativeSpeakerLorauaName, forKey: .nativeSpeakerLorauaName)
        try container.encode(profileIntroLorauaBio, forKey: .profileIntroLorauaBio)
        try container.encode(languagePairingLorauaSummary, forKey: .languagePairingLorauaSummary)
    }
}

private extension KeyedDecodingContainer where Key == LirauGlobalCitizenLorauaAccountProfile.CodingKeys {
    func decodeCompatibleString(primary: Key, legacy: Key) throws -> String {
        if let value = try decodeIfPresent(String.self, forKey: primary) {
            return value
        }
        if let value = try decodeIfPresent(String.self, forKey: legacy) {
            return value
        }
        return ""
    }
}
