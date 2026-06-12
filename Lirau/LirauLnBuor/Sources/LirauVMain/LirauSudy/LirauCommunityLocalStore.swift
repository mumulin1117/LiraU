import Foundation

final class LirauCommunityLocalStore {
    static let shared = LirauCommunityLocalStore()

    private let defaults: UserDefaults
    private let challengeStorageKey = "lirau_community_challenges_v3"
    private let userStateStorageKey = "lirau_community_user_states_v1"
    private let legacyChallengeStorageKey = "lirau_community_challenges_v2"
    private let launchCountLimit = 29
    private let decoder = JSONDecoder()
    private let encoder = JSONEncoder()

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    func getChallenges() -> [LirauCommunityChallenge] {
        let states = loadUserStates()
        return loadStoredChallenges().map { challenge in
            challenge.applyingUserState(resolvedState(for: challenge, states: states))
        }
    }

    func getChallengeById(_ id: String) -> LirauCommunityChallenge? {
        let states = loadUserStates()
        guard let challenge = loadStoredChallenges().first(where: { $0.id == id }) else {
            return nil
        }
        return challenge.applyingUserState(resolvedState(for: challenge, states: states))
    }

    @discardableResult
    func joinChallenge(
        challengeID: String,
        sentence: String,
        translation: String
    ) -> Result<LirauCommunityChallenge, LirauCommunityStateError> {
        let now = Date()
        let user = LirauCommunityUserSnapshot.current
        var challenges = loadStoredChallenges()
        var states = loadUserStates()

        guard let challengeIndex = challenges.firstIndex(where: { $0.id == challengeID }) else {
            return .failure(.challengeNotFound)
        }

        var challenge = challenges[challengeIndex]
        let currentState = state(for: challengeID, in: states)
        let entryID = makeLocalEntryID(challengeID: challengeID, userID: user.userID, now: now)

        switch LirauCommunityStateMachine.joinedState(
            for: challenge,
            current: currentState,
            entryID: entryID,
            now: now
        ) {
        case .failure(let error):
            return .failure(error)
        case .success(let nextState):
            let cleanSentence = sentence.trimmingCharacters(in: .whitespacesAndNewlines)
            let cleanTranslation = translation.trimmingCharacters(in: .whitespacesAndNewlines)
            let entry = LirauCommunityEntry(
                id: entryID,
                challengeID: challengeID,
                userID: user.userID,
                userName: "You",
                sentence: cleanSentence.isEmpty ? "I want to practice one friendly sentence today." : cleanSentence,
                translation: cleanTranslation.isEmpty ? "Shared from \(user.languagePairing)" : cleanTranslation,
                accentNote: user.languagePairing,
                voteCount: 0,
                likeCount: 0,
                commentCount: 0,
                avatarAssetName: "lira_profile_avatar_default",
                colorHex: "#B846FF",
                createdAt: now
            )

            challenge.entries.insert(entry, at: 0)
            challenge.joinedCount = max(challenge.joinedCount + 1, challenge.entries.count)
            challenge.commentCount += 1
            challenge.comments.insert(
                LirauCommunityComment(
                    id: "comment_\(entryID)",
                    userName: "You",
                    message: "I joined with a new language practice entry.",
                    createdAt: now
                ),
                at: 0
            )

            states[challengeID] = nextState
            challenges[challengeIndex] = challenge
            challenges = normalizedLaunchScale(challenges)
            guard saveChallenges(challenges), saveUserStates(states) else {
                return .failure(.localPersistenceFailed)
            }
            return .success((challenges.first { $0.id == challengeID } ?? challenge).applyingUserState(nextState))
        }
    }

    @discardableResult
    func voteOnly(challengeID: String) -> Result<LirauCommunityChallenge, LirauCommunityStateError> {
        let now = Date()
        var states = loadUserStates()

        guard let challenge = loadStoredChallenges().first(where: { $0.id == challengeID }) else {
            return .failure(.challengeNotFound)
        }

        let currentState = state(for: challengeID, in: states)
        switch LirauCommunityStateMachine.voteOnlyState(
            for: challenge,
            current: currentState,
            now: now
        ) {
        case .failure(let error):
            return .failure(error)
        case .success(let nextState):
            states[challengeID] = nextState
            guard saveUserStates(states) else {
                return .failure(.localPersistenceFailed)
            }
            return .success(challenge.applyingUserState(nextState))
        }
    }

    @discardableResult
    func voteEntry(
        challengeID: String,
        entryID: String
    ) -> Result<LirauCommunityChallenge, LirauCommunityStateError> {
        let now = Date()
        let user = LirauCommunityUserSnapshot.current
        var challenges = loadStoredChallenges()
        var states = loadUserStates()

        guard let challengeIndex = challenges.firstIndex(where: { $0.id == challengeID }) else {
            return .failure(.challengeNotFound)
        }

        var challenge = challenges[challengeIndex]
        guard let entryIndex = challenge.entries.firstIndex(where: { $0.id == entryID }) else {
            return .failure(.entryNotFound)
        }

        let currentState = state(for: challengeID, in: states)
        switch LirauCommunityStateMachine.votedState(
            for: challenge,
            entryID: entryID,
            current: currentState,
            profileIntroLorauaCurrentUserID: user.userID,
            now: now
        ) {
        case .failure(let error):
            return .failure(error)
        case .success(let nextState):
            challenge.entries[entryIndex].voteCount += 1
            states[challengeID] = nextState
            challenges[challengeIndex] = challenge
            challenges = normalizedLaunchScale(challenges)
            guard saveChallenges(challenges), saveUserStates(states) else {
                return .failure(.localPersistenceFailed)
            }
            return .success((challenges.first { $0.id == challengeID } ?? challenge).applyingUserState(nextState))
        }
    }

    @discardableResult
    func createChallenge(draft: LirauCommunityChallengeDraft) -> LirauCommunityChallenge {
        let now = Date()
        let user = LirauCommunityUserSnapshot.current
        var challenges = loadStoredChallenges()
        var states = loadUserStates()

        let cleanTitle = draft.title.trimmingCharacters(in: .whitespacesAndNewlines)
        let cleanPrompt = draft.prompt.trimmingCharacters(in: .whitespacesAndNewlines)
        let cleanLanguage = draft.language.trimmingCharacters(in: .whitespacesAndNewlines)
        let durationHours = max(1, draft.durationHours)
        let challengeID = "challenge_created_\(UUID().uuidString)"
        let coverAssetName = draft.coverAssetName.isEmpty ? "lira_community_challenge_cover" : draft.coverAssetName

        let challenge = LirauCommunityMockData.makeChallenge(
            id: challengeID,
            title: cleanTitle.isEmpty ? "New Language Practice" : cleanTitle,
            language: cleanLanguage.isEmpty ? "Spanish" : cleanLanguage,
            subtitle: "Hosted by You",
            prompt: cleanPrompt.isEmpty ? "Write one sentence and help LiraU learners practice together." : cleanPrompt,
            hostName: "You",
            hostUserID: user.userID,
            coverAssetName: coverAssetName,
            localImageURI: draft.localImageURI,
            phase: .open,
            durationLabel: durationLabel(for: durationHours),
            durationHours: durationHours,
            endsAt: now.addingTimeInterval(TimeInterval(durationHours) * 3600),
            joinedCount: 0,
            baseVoteCount: 0,
            likeCount: 0,
            commentCount: 0,
            rules: [
                "Learners answer with one short public sentence.",
                "Entries should stay respectful, language-focused and useful.",
                "Hosts can view entries but can't submit or vote in their own challenge."
            ],
            entries: [],
            comments: [],
            isCreatedByCurrentUser: true,
            createdAt: now
        )

        challenges.insert(challenge, at: 0)
        states[challengeID] = LirauCommunityLocalUserChallengeState(
            challengeID: challengeID,
            role: .host,
            myEntryID: nil,
            votedEntryIDs: [],
            updatedAt: now
        )
        saveChallenges(challenges)
        saveUserStates(states)
        return challenge.applyingUserState(states[challengeID])
    }

    func resetLocalCommunityData() {
        defaults.removeObject(forKey: challengeStorageKey)
        defaults.removeObject(forKey: userStateStorageKey)
        defaults.removeObject(forKey: legacyChallengeStorageKey)
        saveChallenges(LirauCommunityMockData.seedChallenges())
    }

    func loadChallenges() -> [LirauCommunityChallenge] {
        getChallenges()
    }

    func challenge(with id: String) -> LirauCommunityChallenge? {
        getChallengeById(id)
    }

    @discardableResult
    func joinChallengeWithEntry(
        challengeID: String,
        sentence: String,
        translation: String = ""
    ) -> Result<LirauCommunityChallenge, LirauCommunityStateError> {
        joinChallenge(
            challengeID: challengeID,
            sentence: sentence,
            translation: translation
        )
    }

    private func loadStoredChallenges() -> [LirauCommunityChallenge] {
        guard let data = defaults.data(forKey: challengeStorageKey),
              let decoded = try? decoder.decode([LirauCommunityChallenge].self, from: data),
              !decoded.isEmpty else {
            let seeds = LirauCommunityMockData.seedChallenges()
            saveChallenges(seeds)
            return seeds
        }
        let normalized = normalizedLaunchScale(decoded)
        if normalized != decoded {
            saveChallenges(normalized)
        }
        return normalized
    }

    @discardableResult
    private func saveChallenges(_ challenges: [LirauCommunityChallenge]) -> Bool {
        let normalized = normalizedLaunchScale(challenges)
        guard let data = try? encoder.encode(normalized) else { return false }
        defaults.set(data, forKey: challengeStorageKey)
        return true
    }

    private func normalizedLaunchScale(_ challenges: [LirauCommunityChallenge]) -> [LirauCommunityChallenge] {
        challenges.map { normalizedLaunchScale($0) }
    }

    private func normalizedLaunchScale(_ challenge: LirauCommunityChallenge) -> LirauCommunityChallenge {
        var challenge = challenge
        challenge.joinedCount = min(max(0, challenge.joinedCount), launchCountLimit)
        challenge.baseVoteCount = max(0, challenge.baseVoteCount)
        challenge.likeCount = min(max(0, challenge.likeCount), launchCountLimit)

        challenge.entries = challenge.entries.map { entry in
            var entry = entry
            entry.voteCount = max(0, entry.voteCount)
            entry.likeCount = min(max(0, entry.likeCount), launchCountLimit)
            return entry
        }

        let totalVotes = challenge.baseVoteCount + challenge.entries.reduce(0) { $0 + $1.voteCount }
        guard totalVotes > launchCountLimit else {
            return challenge
        }

        let scale = Double(launchCountLimit) / Double(totalVotes)
        challenge.baseVoteCount = Int(Double(challenge.baseVoteCount) * scale)
        for index in challenge.entries.indices {
            challenge.entries[index].voteCount = Int(Double(challenge.entries[index].voteCount) * scale)
        }

        while challenge.baseVoteCount + challenge.entries.reduce(0, { $0 + $1.voteCount }) > launchCountLimit {
            if let index = challenge.entries.indices.max(by: { challenge.entries[$0].voteCount < challenge.entries[$1].voteCount }),
               challenge.entries[index].voteCount > 0 {
                challenge.entries[index].voteCount -= 1
            } else {
                challenge.baseVoteCount = max(0, challenge.baseVoteCount - 1)
            }
        }

        return challenge
    }

    private func loadUserStates() -> [String: LirauCommunityLocalUserChallengeState] {
        guard let data = defaults.data(forKey: userStateStorageKey),
              let decoded = try? decoder.decode([String: LirauCommunityLocalUserChallengeState].self, from: data) else {
            return [:]
        }
        return decoded
    }

    @discardableResult
    private func saveUserStates(_ states: [String: LirauCommunityLocalUserChallengeState]) -> Bool {
        guard let data = try? encoder.encode(states) else { return false }
        defaults.set(data, forKey: userStateStorageKey)
        return true
    }

    private func state(
        for challengeID: String,
        in states: [String: LirauCommunityLocalUserChallengeState]
    ) -> LirauCommunityLocalUserChallengeState {
        states[challengeID] ?? LirauCommunityLocalUserChallengeState(challengeID: challengeID)
    }

    private func resolvedState(
        for challenge: LirauCommunityChallenge,
        states: [String: LirauCommunityLocalUserChallengeState]
    ) -> LirauCommunityLocalUserChallengeState? {
        if let state = states[challenge.id] {
            return state
        }
        let user = LirauCommunityUserSnapshot.current
        if challenge.isCreatedByCurrentUser || challenge.hostUserID == user.userID {
            return LirauCommunityLocalUserChallengeState(
                challengeID: challenge.id,
                role: .host,
                myEntryID: nil,
                votedEntryIDs: [],
                updatedAt: challenge.createdAt
            )
        }
        return nil
    }

    private func makeLocalEntryID(challengeID: String, userID: String, now: Date) -> String {
        "entry_\(challengeID)_\(userID)_\(UUID().uuidString)"
    }

    private func durationLabel(for hours: Int) -> String {
        if hours >= 24, hours % 24 == 0 {
            let days = hours / 24
            return days == 1 ? "Ends in 24h" : "Ends in \(days)d"
        }
        return "Ends in \(hours)h"
    }
}
