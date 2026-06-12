import Foundation

final class LirauOnboardingFlowLorauaStore {
    static let shared = LirauOnboardingFlowLorauaStore()
    
    private let backendArchitectureLorauaBaseURLString = LirauEncryptionLorauaText.backendArchitectureLorauaBaseURL()
    private let onboardingFlowLorauaEmailAuthPath = LirauEncryptionLorauaText.onboardingFlowLorauaEmailAuthPath()
    private let statusIndicatorLorauaSuccessCodes: Set<String> = [LirauEncryptionLorauaText.statusIndicatorLorauaPrimarySuccessCode(), LirauEncryptionLorauaText.statusIndicatorLorauaSecondarySuccessCode()]
    private let appIndexingLorauaAppKey = LirauEncryptionLorauaText.appIndexingLorauaAppKey()
    private let defaults = UserDefaults.standard
    private let eulaKey = "lirau_eula_agreed"
    private let onboardingFlowLorauaIsLoggedInKey = "lirau_is_logged_in"
    private let emailMarketingLorauaCurrentEmailKey = LirauEncryptionLorauaText.emailMarketingLorauaCurrentEmailStorageKey()
    private let usersKey = LirauEncryptionLorauaText.globalCommunityLorauaRegisteredUsersStorageKey()

    let identityVerificationLorauaTestEmail = "lariau@gmail.com"
    let identityVerificationLorauaTestPassword = "454545"

    private init() {}

    var hasAgreedUserAgreementLoraua: Bool {
        get { defaults.bool(forKey: eulaKey) }
        set { defaults.set(newValue, forKey: eulaKey) }
    }

    var onboardingFlowLorauaIsLoggedIn: Bool {
        get { defaults.bool(forKey: onboardingFlowLorauaIsLoggedInKey) }
        set { defaults.set(newValue, forKey: onboardingFlowLorauaIsLoggedInKey) }
    }

    var emailMarketingLorauaCurrentEmail: String? {
        get { defaults.string(forKey: emailMarketingLorauaCurrentEmailKey) }
        set { defaults.set(newValue, forKey: emailMarketingLorauaCurrentEmailKey) }
    }

    var globalCitizenLorauaCurrentProfile: LirauGlobalCitizenLorauaAccountProfile? {
        guard let emailMarketingLorauaCurrentEmail else { return nil }
        return users[emailMarketingLorauaCurrentEmail]
    }

    var sessionTokenLoraua: String? {
        get { defaults.object(forKey: LirauEncryptionLorauaText.pointSystemLorauaSessionTokenStorageKey()) as? String }
        set {
            if let newValue {
                defaults.set(newValue, forKey: LirauEncryptionLorauaText.pointSystemLorauaSessionTokenStorageKey())
            } else {
                defaults.removeObject(forKey: LirauEncryptionLorauaText.pointSystemLorauaSessionTokenStorageKey())
            }
        }
    }

    func identityVerificationLorauaLogin(email: String, password: String, completion: @escaping (Result<LirauGlobalCitizenLorauaAccountProfile, LirauIdentityVerificationLorauaError>) -> Void) {
        let normalizedEmail = email.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        guard !normalizedEmail.isEmpty else {
            completion(.failure(.emptyEmail))
            return
        }
        guard !password.isEmpty else {
            completion(.failure(.emptyPassword))
            return
        }

        requestOnboardingFlowLorauaEmailAuth(
            email: normalizedEmail,
            password: password,
            displayName: nil,
            profileIntroLoraua: nil
        ) { [weak self] remoteResult in
            guard let self else { return }
            DispatchQueue.main.async {
                switch remoteResult {
                case .success(let remoteProfile):
                    self.save(profile: remoteProfile)
                    self.markLoggedIn(email: remoteProfile.emailMarketingLorauaAddress)
                    completion(.success(remoteProfile))
                case .failure(let error):
                    completion(.failure(error))
                }
            }
        }
    }

    func onboardingFlowLorauaCanRegister(email: String, password: String) -> Result<String, LirauIdentityVerificationLorauaError> {
        let normalizedEmail = email.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        guard isValidEmail(normalizedEmail) else { return .failure(.invalidEmail) }
        guard password.count >= 6 else { return .failure(.shortPassword) }
        return .success(normalizedEmail)
    }

    func onboardingFlowLorauaRegister(profile: LirauGlobalCitizenLorauaAccountProfile, password: String, completion: @escaping (Result<LirauGlobalCitizenLorauaAccountProfile, LirauIdentityVerificationLorauaError>) -> Void) {
        requestOnboardingFlowLorauaEmailAuth(
            email: profile.emailMarketingLorauaAddress,
            password: password,
            displayName: profile.nativeSpeakerLorauaName,
            profileIntroLoraua: profile.profileIntroLorauaBio
        ) { [weak self] remoteResult in
            guard let self else { return }
            DispatchQueue.main.async {
                let finalProfile: LirauGlobalCitizenLorauaAccountProfile
                switch remoteResult {
                case .success(let remoteProfile):
                    finalProfile = profile.mergingRemoteGlobalCitizenLorauaProfile(remoteProfile, fallbackPassword: password)
                    self.save(profile: finalProfile)
                    self.markLoggedIn(email: finalProfile.emailMarketingLorauaAddress)
                    completion(.success(finalProfile))
                case .failure(let error):
                    completion(.failure(error))
                    return
                }
            }
        }
    }

    func onboardingFlowLorauaLogout() {
        onboardingFlowLorauaIsLoggedIn = false
        emailMarketingLorauaCurrentEmail = nil
    }

    private var users: [String: LirauGlobalCitizenLorauaAccountProfile] {
        get {
            guard let data = defaults.data(forKey: usersKey),
                  let decoded = try? JSONDecoder().decode([String: LirauGlobalCitizenLorauaAccountProfile].self, from: data) else {
                return [:]
            }
            return decoded
        }
        set {
            let data = try? JSONEncoder().encode(newValue)
            defaults.set(data, forKey: usersKey)
        }
    }

    private func save(profile: LirauGlobalCitizenLorauaAccountProfile) {
        var storedUsers = users
        storedUsers[profile.emailMarketingLorauaAddress] = profile
        users = storedUsers
        sessionTokenLoraua = profile.pointSystemLorauaToken
        if let numericUserID = Int(profile.globalCitizenLorauaID) {
            defaults.set(numericUserID, forKey: LirauEncryptionLorauaText.identityVerificationLorauaUserIDStorageKey())
        } else {
            defaults.set(profile.globalCitizenLorauaID, forKey: LirauEncryptionLorauaText.identityVerificationLorauaUserIDStorageKey())
        }
    }

    private func markLoggedIn(email: String) {
        emailMarketingLorauaCurrentEmail = email
        onboardingFlowLorauaIsLoggedIn = true
    }

    private func isValidEmail(_ email: String) -> Bool {
        let pattern = #"^[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$"#
        return email.range(of: pattern, options: .regularExpression) != nil
    }

    private func requestOnboardingFlowLorauaEmailAuth(
        email: String,
        password: String,
        displayName: String?,
        profileIntroLoraua: String?,
        completion: @escaping (Result<LirauGlobalCitizenLorauaAccountProfile, LirauIdentityVerificationLorauaError>) -> Void
    ) {
        guard let url = apiFirstLorauaEndpointURL(path: onboardingFlowLorauaEmailAuthPath) else {
            completion(.failure(.remoteUnavailable))
            return
        }

        var payload: [String: String] = [
            "limitedTimeEventLoraua": appIndexingLorauaAppKey,
            "leaderboardRankingLoraua": email,
            "dailyQuestLoraua": password
        ]
        if let displayName, !displayName.isEmpty {
            payload["conversionOptimizationLoraua"] = displayName
        }
        if let profileIntroLoraua, !profileIntroLoraua.isEmpty {
            payload["inAppPurchaseLoraua"] = profileIntroLoraua
        }

        var request = URLRequest(url: url, cachePolicy: .useProtocolCachePolicy, timeoutInterval: 30)
        request.httpMethod = LirauEncryptionLorauaText.restfulAPILorauaPostMethod()
        request.setValue(LirauEncryptionLorauaText.apiFirstLorauaJSONMimeType(), forHTTPHeaderField: LirauEncryptionLorauaText.apiFirstLorauaContentTypeHeader())
        request.setValue(LirauEncryptionLorauaText.apiFirstLorauaJSONMimeType(), forHTTPHeaderField: LirauEncryptionLorauaText.restfulAPILorauaAcceptHeader())
        request.setValue(appIndexingLorauaAppKey, forHTTPHeaderField: LirauEncryptionLorauaText.apiFirstLorauaKeyHeader())
        request.setValue(sessionTokenLoraua ?? "", forHTTPHeaderField: LirauEncryptionLorauaText.pointSystemLorauaTokenHeader())
       
        request.httpBody = try? JSONSerialization.data(withJSONObject: payload, options: [])
        NSLog(
            "LiraU API Request Auth: url=%@ params=%@ token=%@",
            url.absoluteString,
            dataAnalyticsLorauaDebugJSONString(dailyQuestLorauaMaskedPayload(payload)),
            pointSystemLorauaMaskedToken(sessionTokenLoraua)
        )

        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 30

        URLSession(configuration: configuration).dataTask(with: request) { [weak self] data, response, error in
            guard let self else { return }
            if let error {
                NSLog("LiraU API Failure Auth: url=%@ error=%@", url.absoluteString, error.localizedDescription)
                completion(.failure(.remoteUnavailable))
                return
            }
            guard let data else {
                NSLog("LiraU API Failure Auth: url=%@ error=no data", url.absoluteString)
                completion(.failure(.remoteUnavailable))
                return
            }

            let statusCode = (response as? HTTPURLResponse)?.statusCode ?? -1
            let rawText = String(data: data, encoding: .utf8) ?? "<non-utf8 response>"
            NSLog("LiraU API Response Auth: url=%@ status=%ld raw=%@", url.absoluteString, statusCode, rawText)

            do {
                guard let json = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: Any] else {
                    self.logInvalidIdentityVerificationLorauaResponse(data: data, response: response)
                    completion(.failure(.remoteUnavailable))
                    return
                }
                let code = "\(json[LirauEncryptionLorauaText.restfulAPILorauaResponseCodeKey()] ?? json[LirauEncryptionLorauaText.statusIndicatorLorauaResponseStatusKey()] ?? "")"
                NSLog("LiraU API Parsed Auth: code=%@ data=%@", code, self.dataAnalyticsLorauaDebugJSONString(json[LirauEncryptionLorauaText.dataAnalyticsLorauaResponseDataKey()]))
                guard self.statusIndicatorLorauaSuccessCodes.contains(code) else {
                    completion(.failure(.remoteUnavailable))
                    return
                }
                let profile = self.profileIntroLorauaFromAuthResponse(
                    json[LirauEncryptionLorauaText.dataAnalyticsLorauaResponseDataKey()],
                    fallbackEmail: email,
                    fallbackPassword: password,
                    fallbackName: displayName,
                    fallbackIntro: profileIntroLoraua
                )
                completion(.success(profile))
            } catch {
                self.logInvalidIdentityVerificationLorauaResponse(data: data, response: response)
                completion(.failure(.remoteUnavailable))
            }
        }.resume()
    }

    private func logInvalidIdentityVerificationLorauaResponse(data: Data, response: URLResponse?) {
        let statusCode = (response as? HTTPURLResponse)?.statusCode ?? -1
        let rawText = String(data: data, encoding: .utf8) ?? "<non-utf8 response>"
        NSLog("LiraU auth response is not valid JSON. status=%ld body=%@", statusCode, rawText)
    }

    private func apiFirstLorauaEndpointURL(path: String) -> URL? {
        let base = backendArchitectureLorauaBaseURLString.trimmingCharacters(in: CharacterSet(charactersIn: "/"))
        let endpoint = path.trimmingCharacters(in: CharacterSet(charactersIn: "/"))
        return URL(string: "\(base)/\(endpoint)")
    }

    private func dailyQuestLorauaMaskedPayload(_ payload: [String: String]) -> [String: String] {
        var masked = payload
        if masked["dailyQuestLoraua"] != nil {
            masked["dailyQuestLoraua"] = "<masked>"
        }
        return masked
    }

    private func pointSystemLorauaMaskedToken(_ token: String?) -> String {
        guard let token, !token.isEmpty else { return "<empty>" }
        guard token.count > 8 else { return "<masked>" }
        return "\(token.prefix(4))...\(token.suffix(4))"
    }

    private func dataAnalyticsLorauaDebugJSONString(_ object: Any?) -> String {
        guard let object else { return "<nil>" }
        guard JSONSerialization.isValidJSONObject(object),
              let data = try? JSONSerialization.data(withJSONObject: object, options: [.sortedKeys]),
              let text = String(data: data, encoding: .utf8) else {
            return "\(object)"
        }
        return text
    }

    private func profileIntroLorauaFromAuthResponse(
        _ data: Any?,
        fallbackEmail: String,
        fallbackPassword: String,
        fallbackName: String?,
        fallbackIntro: String?
    ) -> LirauGlobalCitizenLorauaAccountProfile {
        let dictionary = dataAnalyticsLorauaNormalizedDictionaryPayload(data)
        let email = lexicalVarietyLorauaStringValue(dictionary["reviewComplianceLoraua"]).isEmpty ? fallbackEmail : lexicalVarietyLorauaStringValue(dictionary["reviewComplianceLoraua"])
        let userID = lexicalVarietyLorauaStringValue(dictionary[LirauEncryptionLorauaText.identityVerificationLorauaUserIDStorageKey()]).isEmpty ? UUID().uuidString : lexicalVarietyLorauaStringValue(dictionary[LirauEncryptionLorauaText.identityVerificationLorauaUserIDStorageKey()])
        let token = lexicalVarietyLorauaStringValue(dictionary[LirauEncryptionLorauaText.pointSystemLorauaSessionTokenStorageKey()]).isEmpty ? fallbackPassword : lexicalVarietyLorauaStringValue(dictionary[LirauEncryptionLorauaText.pointSystemLorauaSessionTokenStorageKey()])
        let displayName = lexicalVarietyLorauaStringValue(dictionary["assetManagementLoraua"]).isEmpty ? (fallbackName ?? "LiraU Learner") : lexicalVarietyLorauaStringValue(dictionary["assetManagementLoraua"])
        let intro = lexicalVarietyLorauaStringValue(dictionary["appStoreSubmissionLoraua"]).isEmpty ? (fallbackIntro ?? "Ready to share everyday language and culture.") : lexicalVarietyLorauaStringValue(dictionary["appStoreSubmissionLoraua"])
        return LirauGlobalCitizenLorauaAccountProfile(
            globalCitizenLorauaID: userID,
            pointSystemLorauaToken: token,
            emailMarketingLorauaAddress: email.trimmingCharacters(in: .whitespacesAndNewlines).lowercased(),
            nativeSpeakerLorauaName: displayName,
            profileIntroLorauaBio: intro,
            languagePairingLorauaSummary: "English - Global culture"
        )
    }

    private func dataAnalyticsLorauaNormalizedDictionaryPayload(_ data: Any?) -> [String: Any] {
        if let dictionary = data as? [String: Any] {
            return dictionary
        }
        if let array = data as? [[String: Any]], let first = array.first {
            return first
        }
        return [:]
    }

    private func lexicalVarietyLorauaStringValue(_ value: Any?) -> String {
        if let value = value as? String {
            return value
        }
        if let value {
            return "\(value)"
        }
        return ""
    }
}

enum LirauIdentityVerificationLorauaError: Error {
    case emptyEmail
    case emptyPassword
    case invalidEmail
    case shortPassword
    case accountExists
    case accountMissing
    case incorrectPassword
    case remoteUnavailable

    var message: String {
        switch self {
        case .emptyEmail:
            return "Email is required."
        case .emptyPassword:
            return "Password is required."
        case .invalidEmail:
            return "Enter a valid email address."
        case .shortPassword:
            return "Password must be at least 6 characters."
        case .accountExists:
            return "Account already exists."
        case .accountMissing:
            return "Account does not exist."
        case .incorrectPassword:
            return "Incorrect password."
        case .remoteUnavailable:
            return "LiraU account service is unavailable. Please try again."
        }
    }
}
