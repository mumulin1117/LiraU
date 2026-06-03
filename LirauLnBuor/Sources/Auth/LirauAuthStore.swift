import Foundation

final class LirauAuthStore {
    static let shared = LirauAuthStore()

    private let defaults = UserDefaults.standard
    private let eulaKey = "lirau_eula_agreed"
    private let isLoggedInKey = "lirau_is_logged_in"
    private let currentEmailKey = "lirau_current_email"
    private let usersKey = "lirau_registered_users"

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
        if currentEmail == testEmail {
            return users[currentEmail] ?? .testProfile
        }
        return users[currentEmail]
    }

    func login(email: String, password: String) -> Result<LirauUserProfile, LirauAuthError> {
        let normalizedEmail = email.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        guard !normalizedEmail.isEmpty else { return .failure(.emptyEmail) }
        guard !password.isEmpty else { return .failure(.emptyPassword) }

        if normalizedEmail == testEmail {
            guard password == testPassword else { return .failure(.incorrectPassword) }
            var storedUsers = users
            storedUsers[normalizedEmail] = .testProfile
            users = storedUsers
            markLoggedIn(email: normalizedEmail)
            return .success(.testProfile)
        }

        guard let profile = users[normalizedEmail] else {
            return .failure(.accountMissing)
        }

        guard password == profile.token else {
            return .failure(.incorrectPassword)
        }

        markLoggedIn(email: normalizedEmail)
        return .success(profile)
    }

    func canRegister(email: String, password: String) -> Result<String, LirauAuthError> {
        let normalizedEmail = email.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        guard isValidEmail(normalizedEmail) else { return .failure(.invalidEmail) }
        guard password.count >= 6 else { return .failure(.shortPassword) }
        guard users[normalizedEmail] == nil else { return .failure(.accountExists) }
        return .success(normalizedEmail)
    }

    func register(profile: LirauUserProfile) {
        var storedUsers = users
        storedUsers[profile.email] = profile
        users = storedUsers
        markLoggedIn(email: profile.email)
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

    private func markLoggedIn(email: String) {
        currentEmail = email
        isLoggedIn = true
    }

    private func isValidEmail(_ email: String) -> Bool {
        let pattern = #"^[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$"#
        return email.range(of: pattern, options: .regularExpression) != nil
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
        }
    }
}
