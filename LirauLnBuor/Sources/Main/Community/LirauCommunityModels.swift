import UIKit

enum LirauCommunityFilter: CaseIterable {
    case all
    case ended
    case hot

    var title: String {
        switch self {
        case .all: return "All"
        case .ended: return "Ended"
        case .hot: return "Hot"
        }
    }
}

enum LirauCommunityChallengePhase: String, Codable {
    case open
    case voting
    case ended

    var legacyStatus: LirauCommunityChallengeStatus {
        switch self {
        case .open: return .live
        case .voting: return .voting
        case .ended: return .ended
        }
    }
}

enum LirauCommunityChallengeStatus: String, Codable {
    case live
    case voting
    case ended

    var phase: LirauCommunityChallengePhase {
        switch self {
        case .live: return .open
        case .voting: return .voting
        case .ended: return .ended
        }
    }

    var title: String {
        switch self {
        case .live: return "Live"
        case .voting: return "Voting"
        case .ended: return "Ended"
        }
    }

    var actionTitle: String {
        switch self {
        case .live: return "Join"
        case .voting: return "Vote"
        case .ended: return "See results"
        }
    }

    var foregroundColor: UIColor {
        switch self {
        case .live: return UIColor(red: 0.34, green: 1.0, blue: 0.66, alpha: 1)
        case .voting: return UIColor(red: 1.0, green: 0.75, blue: 0.25, alpha: 1)
        case .ended: return UIColor(red: 0.72, green: 0.72, blue: 0.82, alpha: 1)
        }
    }

    var backgroundColor: UIColor {
        switch self {
        case .live: return UIColor(red: 0.12, green: 0.5, blue: 0.28, alpha: 0.24)
        case .voting: return UIColor(red: 0.68, green: 0.42, blue: 0.05, alpha: 0.24)
        case .ended: return UIColor.white.withAlphaComponent(0.12)
        }
    }
}

enum LirauCommunityUserRole: String, Codable {
    case none
    case host
    case joined
    case voteOnly

    var legacyMode: LirauCommunityUserMode {
        switch self {
        case .none: return .none
        case .host: return .host
        case .joined: return .submitted
        case .voteOnly: return .voteOnly
        }
    }
}

enum LirauCommunityUserMode: String, Codable {
    case none
    case host
    case submitted
    case voteOnly

    var role: LirauCommunityUserRole {
        switch self {
        case .none: return .none
        case .host: return .host
        case .submitted: return .joined
        case .voteOnly: return .voteOnly
        }
    }
}

struct LirauCommunityChallengeDraft {
    var title: String
    var language: String
    var prompt: String
    var coverAssetName: String
    var localImageURI: String?
    var durationHours: Int
}

struct LirauCommunityEntry: Codable, Equatable {
    var id: String
    var challengeID: String
    var userID: String
    var userName: String
    var sentence: String
    var translation: String
    var accentNote: String
    var voteCount: Int
    var likeCount: Int
    var commentCount: Int
    var avatarAssetName: String?
    var colorHex: String
    var createdAt: Date

    var authorName: String { userName }
    var text: String { sentence }
    var votes: Int { voteCount }
}

struct LirauCommunityComment: Codable, Equatable {
    var id: String
    var userName: String
    var message: String
    var createdAt: Date
}

struct LirauCommunityLocalUserChallengeState: Codable, Equatable {
    var challengeID: String
    var role: LirauCommunityUserRole
    var myEntryID: String?
    var votedEntryIDs: [String]
    var updatedAt: Date

    init(
        challengeID: String,
        role: LirauCommunityUserRole = .none,
        myEntryID: String? = nil,
        votedEntryIDs: [String] = [],
        updatedAt: Date = Date()
    ) {
        self.challengeID = challengeID
        self.role = role
        self.myEntryID = myEntryID
        self.votedEntryIDs = votedEntryIDs
        self.updatedAt = updatedAt
    }

    mutating func recordVote(entryID: String, now: Date = Date()) {
        guard !votedEntryIDs.contains(entryID) else { return }
        votedEntryIDs.append(entryID)
        if role == .none {
            role = .voteOnly
        }
        updatedAt = now
    }
}

struct LirauCommunityChallenge: Codable, Equatable {
    var id: String
    var title: String
    var language: String
    var subtitle: String
    var prompt: String
    var hostName: String
    var hostUserID: String
    var coverAssetName: String
    var localImageURI: String?
    var status: LirauCommunityChallengeStatus
    var durationLabel: String
    var durationHours: Int?
    var endsAt: Date?
    var joinedCount: Int
    var baseVoteCount: Int
    var likeCount: Int
    var commentCount: Int
    var rules: [String]
    var entries: [LirauCommunityEntry]
    var comments: [LirauCommunityComment]
    var currentUserMode: LirauCommunityUserMode
    var currentUserEntryID: String?
    var votedEntryID: String?
    var currentUserVotedEntryIDs: [String]?
    var isLikedByCurrentUser: Bool
    var isCreatedByCurrentUser: Bool
    var isHotPinned: Bool
    var createdAt: Date

    var phase: LirauCommunityChallengePhase {
        get { status.phase }
        set { status = newValue.legacyStatus }
    }

    var totalVoteCount: Int {
        baseVoteCount + entries.reduce(0) { $0 + $1.voteCount }
    }

    var isHot: Bool {
        isHotPinned || totalVoteCount >= 2000 || likeCount >= 25 || status == .voting
    }

    var participantText: String {
        "\(joinedCount) joined"
    }

    var voteText: String {
        LirauCommunityFormatter.compact(totalVoteCount)
    }

    var commentText: String {
        "\(commentCount) comments"
    }

    var currentUserEntry: LirauCommunityEntry? {
        guard let currentUserEntryID else { return nil }
        return entries.first { $0.id == currentUserEntryID }
    }

    func applyingUserState(_ state: LirauCommunityLocalUserChallengeState?) -> LirauCommunityChallenge {
        guard let state else { return self }
        var challenge = self
        challenge.currentUserMode = state.role.legacyMode
        challenge.currentUserEntryID = state.myEntryID
        challenge.votedEntryID = state.votedEntryIDs.first
        challenge.currentUserVotedEntryIDs = state.votedEntryIDs
        return challenge
    }

    var recordedVotedEntryIDs: [String] {
        if let currentUserVotedEntryIDs {
            return currentUserVotedEntryIDs
        }
        if let votedEntryID {
            return [votedEntryID]
        }
        return []
    }

    var displayCoverImage: UIImage? {
        if let localImageURI, let image = LirauCommunityChallenge.image(fromLocalImageURI: localImageURI) {
            return image
        }
        return UIImage(named: coverAssetName) ?? UIImage(named: "lira_profile_post_placeholder")
    }

    private static func image(fromLocalImageURI uri: String) -> UIImage? {
        if let fileURL = URL(string: uri), fileURL.isFileURL {
            return UIImage(contentsOfFile: fileURL.path)
        }
        return UIImage(contentsOfFile: uri)
    }
}

struct LirauCommunityUserSnapshot {
    var userID: String
    var displayName: String
    var languagePairing: String

    static var current: LirauCommunityUserSnapshot {
        let profile = LirauAuthStore.shared.currentUser ?? LirauUserProfile.testProfile
        return LirauCommunityUserSnapshot(
            userID: profile.userID.isEmpty ? "lirau_local_learner" : profile.userID,
            displayName: profile.displayName.isEmpty ? "LiraU Speaker" : profile.displayName,
            languagePairing: profile.languagePairingLoraua.isEmpty ? "English - Spanish" : profile.languagePairingLoraua
        )
    }
}
