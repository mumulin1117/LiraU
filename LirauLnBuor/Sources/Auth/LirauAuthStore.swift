import Foundation

final class LirauAuthStore {
    static let shared = LirauAuthStore()
    
    private let authBaseURLString = LirauCipherText.backendBaseURL()
    private let emailAuthPath = LirauCipherText.emailAuthPath()
    private let authSuccessCodes: Set<String> = [LirauCipherText.primarySuccessCode(), LirauCipherText.secondarySuccessCode()]
    private let appKey = LirauCipherText.appKey()
    private let defaults = UserDefaults.standard
    private let eulaKey = "lirau_eula_agreed"
    private let isLoggedInKey = "lirau_is_logged_in"
    private let currentEmailKey = LirauCipherText.currentEmailStorageKey()
    private let usersKey = LirauCipherText.registeredUsersStorageKey()

    let testEmail = "lariau@gmail.com"
    let testPassword = "454545"

    private init() {}

    var hasAgreedEULA: Bool {
        get { defaults.bool(forKey: eulaKey) }
        set { defaults.set(newValue, forKey: eulaKey) }
    }

    var isLoggedIn: Bool {
        get { defaults.bool(forKey: isLoggedInKey) }
        set { defaults.set(newValue, forKey: isLoggedInKey) }
    }

    var currentEmail: String? {
        get { defaults.string(forKey: currentEmailKey) }
        set { defaults.set(newValue, forKey: currentEmailKey) }
    }

    var currentUser: LirauUserProfile? {
        guard let currentEmail else { return nil }
        return users[currentEmail]
    }

    var sessionTokenLoraua: String? {
        get { defaults.object(forKey: LirauCipherText.sessionTokenStorageKey()) as? String }
        set {
            if let newValue {
                defaults.set(newValue, forKey: LirauCipherText.sessionTokenStorageKey())
            } else {
                defaults.removeObject(forKey: LirauCipherText.sessionTokenStorageKey())
            }
        }
    }

    func login(email: String, password: String, completion: @escaping (Result<LirauUserProfile, LirauAuthError>) -> Void) {
        let normalizedEmail = email.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        guard !normalizedEmail.isEmpty else {
            completion(.failure(.emptyEmail))
            return
        }
        guard !password.isEmpty else {
            completion(.failure(.emptyPassword))
            return
        }

        requestEmailAuth(
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
                    self.markLoggedIn(email: remoteProfile.email)
                    completion(.success(remoteProfile))
                case .failure(let error):
                    completion(.failure(error))
                }
            }
        }
    }

    func canRegister(email: String, password: String) -> Result<String, LirauAuthError> {
        let normalizedEmail = email.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        guard isValidEmail(normalizedEmail) else { return .failure(.invalidEmail) }
        guard password.count >= 6 else { return .failure(.shortPassword) }
        return .success(normalizedEmail)
    }

    func register(profile: LirauUserProfile, password: String, completion: @escaping (Result<LirauUserProfile, LirauAuthError>) -> Void) {
        requestEmailAuth(
            email: profile.email,
            password: password,
            displayName: profile.displayName,
            profileIntroLoraua: profile.profileIntroLoraua
        ) { [weak self] remoteResult in
            guard let self else { return }
            DispatchQueue.main.async {
                let finalProfile: LirauUserProfile
                switch remoteResult {
                case .success(let remoteProfile):
                    finalProfile = profile.mergingRemoteProfile(remoteProfile, fallbackPassword: password)
                    self.save(profile: finalProfile)
                    self.markLoggedIn(email: finalProfile.email)
                    completion(.success(finalProfile))
                case .failure(let error):
                    completion(.failure(error))
                    return
                }
            }
        }
    }

    func logout() {
        isLoggedIn = false
        currentEmail = nil
    }

    private var users: [String: LirauUserProfile] {
        get {
            guard let data = defaults.data(forKey: usersKey),
                  let decoded = try? JSONDecoder().decode([String: LirauUserProfile].self, from: data) else {
                return [:]
            }
            return decoded
        }
        set {
            let data = try? JSONEncoder().encode(newValue)
            defaults.set(data, forKey: usersKey)
        }
    }

    private func save(profile: LirauUserProfile) {
        var storedUsers = users
        storedUsers[profile.email] = profile
        users = storedUsers
        sessionTokenLoraua = profile.Token
        if let numericUserID = Int(profile.userID) {
            defaults.set(numericUserID, forKey: LirauCipherText.userIDStorageKey())
        } else {
            defaults.set(profile.userID, forKey: LirauCipherText.userIDStorageKey())
        }
    }

    private func markLoggedIn(email: String) {
        currentEmail = email
        isLoggedIn = true
    }

    private func isValidEmail(_ email: String) -> Bool {
        let pattern = #"^[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$"#
        return email.range(of: pattern, options: .regularExpression) != nil
    }

    private func requestEmailAuth(
        email: String,
        password: String,
        displayName: String?,
        profileIntroLoraua: String?,
        completion: @escaping (Result<LirauUserProfile, LirauAuthError>) -> Void
    ) {
        guard let url = endpointURL(path: emailAuthPath) else {
            completion(.failure(.remoteUnavailable))
            return
        }

        var payload: [String: String] = [
            "limitedTimeEventLoraua": appKey,
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
        request.httpMethod = LirauCipherText.httpPostMethod()
        request.setValue(LirauCipherText.jsonMimeType(), forHTTPHeaderField: LirauCipherText.contentTypeHeader())
        request.setValue(LirauCipherText.jsonMimeType(), forHTTPHeaderField: LirauCipherText.acceptHeader())
        request.setValue(appKey, forHTTPHeaderField: LirauCipherText.keyHeader())
        request.setValue(sessionTokenLoraua ?? "", forHTTPHeaderField: LirauCipherText.tokenHeader())
       
        request.httpBody = try? JSONSerialization.data(withJSONObject: payload, options: [])
        NSLog(
            "LiraU API Request Auth: url=%@ params=%@ token=%@",
            url.absoluteString,
            debugJSONString(maskedPayload(payload)),
            maskedToken(sessionTokenLoraua)
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
                    self.logInvalidAuthResponse(data: data, response: response)
                    completion(.failure(.remoteUnavailable))
                    return
                }
                let code = "\(json[LirauCipherText.responseCodeKey()] ?? json[LirauCipherText.responseStatusKey()] ?? "")"
                NSLog("LiraU API Parsed Auth: code=%@ data=%@", code, self.debugJSONString(json[LirauCipherText.responseDataKey()]))
                guard self.authSuccessCodes.contains(code) else {
                    completion(.failure(.remoteUnavailable))
                    return
                }
                let profile = self.profileFromAuthResponse(
                    json[LirauCipherText.responseDataKey()],
                    fallbackEmail: email,
                    fallbackPassword: password,
                    fallbackName: displayName,
                    fallbackIntro: profileIntroLoraua
                )
                completion(.success(profile))
            } catch {
                self.logInvalidAuthResponse(data: data, response: response)
                completion(.failure(.remoteUnavailable))
            }
        }.resume()
    }

    private func logInvalidAuthResponse(data: Data, response: URLResponse?) {
        let statusCode = (response as? HTTPURLResponse)?.statusCode ?? -1
        let rawText = String(data: data, encoding: .utf8) ?? "<non-utf8 response>"
        NSLog("LiraU auth response is not valid JSON. status=%ld body=%@", statusCode, rawText)
    }

    private func endpointURL(path: String) -> URL? {
        let base = authBaseURLString.trimmingCharacters(in: CharacterSet(charactersIn: "/"))
        let endpoint = path.trimmingCharacters(in: CharacterSet(charactersIn: "/"))
        return URL(string: "\(base)/\(endpoint)")
    }

    private func maskedPayload(_ payload: [String: String]) -> [String: String] {
        var masked = payload
        if masked["dailyQuestLoraua"] != nil {
            masked["dailyQuestLoraua"] = "<masked>"
        }
        return masked
    }

    private func maskedToken(_ token: String?) -> String {
        guard let token, !token.isEmpty else { return "<empty>" }
        guard token.count > 8 else { return "<masked>" }
        return "\(token.prefix(4))...\(token.suffix(4))"
    }

    private func debugJSONString(_ object: Any?) -> String {
        guard let object else { return "<nil>" }
        guard JSONSerialization.isValidJSONObject(object),
              let data = try? JSONSerialization.data(withJSONObject: object, options: [.sortedKeys]),
              let text = String(data: data, encoding: .utf8) else {
            return "\(object)"
        }
        return text
    }

    private func profileFromAuthResponse(
        _ data: Any?,
        fallbackEmail: String,
        fallbackPassword: String,
        fallbackName: String?,
        fallbackIntro: String?
    ) -> LirauUserProfile {
        let dictionary = normalizedDictionaryPayload(data)
        let email = stringValue(dictionary["reviewComplianceLoraua"]).isEmpty ? fallbackEmail : stringValue(dictionary["reviewComplianceLoraua"])
        let userID = stringValue(dictionary[LirauCipherText.userIDStorageKey()]).isEmpty ? UUID().uuidString : stringValue(dictionary[LirauCipherText.userIDStorageKey()])
        let token = stringValue(dictionary[LirauCipherText.sessionTokenStorageKey()]).isEmpty ? fallbackPassword : stringValue(dictionary[LirauCipherText.sessionTokenStorageKey()])
        let displayName = stringValue(dictionary["assetManagementLoraua"]).isEmpty ? (fallbackName ?? "LiraU Learner") : stringValue(dictionary["assetManagementLoraua"])
        let intro = stringValue(dictionary["appStoreSubmissionLoraua"]).isEmpty ? (fallbackIntro ?? "Ready to share everyday language and culture.") : stringValue(dictionary["appStoreSubmissionLoraua"])
        return LirauUserProfile(
            userID: userID,
            Token: token,
            email: email.trimmingCharacters(in: .whitespacesAndNewlines).lowercased(),
            displayName: displayName,
            profileIntroLoraua: intro,
            languagePairingLoraua: "English - Global culture"
        )
    }

    private func normalizedDictionaryPayload(_ data: Any?) -> [String: Any] {
        if let dictionary = data as? [String: Any] {
            return dictionary
        }
        if let array = data as? [[String: Any]], let first = array.first {
            return first
        }
        return [:]
    }

    private func stringValue(_ value: Any?) -> String {
        if let value = value as? String {
            return value
        }
        if let value {
            return "\(value)"
        }
        return ""
    }
}

enum LirauAuthError: Error {
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
