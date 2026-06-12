import Foundation

enum LirauCommunityStateError: Error, Equatable {
    case challengeNotFound
    case entryNotFound
    case submissionsClosed
    case challengeEnded
    case alreadyJoined
    case voteOnlyCannotJoin
    case hostCannotParticipate
    case duplicateVote
    case cannotVoteOwnEntry
    case localPersistenceFailed
}

extension LirauCommunityStateError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .challengeNotFound:
            return "Challenge was not found."
        case .entryNotFound:
            return "Entry was not found."
        case .submissionsClosed:
            return "This challenge is no longer open for new entries."
        case .challengeEnded:
            return "This challenge has ended."
        case .alreadyJoined:
            return "You have already joined this challenge."
        case .voteOnlyCannotJoin:
            return "You already chose to vote in this challenge."
        case .hostCannotParticipate:
            return "Hosts can view entries but can't submit or vote."
        case .duplicateVote:
            return "You have already voted for this entry."
        case .cannotVoteOwnEntry:
            return "You cannot vote for your own entry."
        case .localPersistenceFailed:
            return "Could not save this entry locally. Please try again."
        }
    }
}

enum LirauCommunityStateMachine {
    static func joinedState(
        for challenge: LirauCommunityChallenge,
        current state: LirauCommunityLocalUserChallengeState,
        entryID: String,
        now: Date = Date()
    ) -> Result<LirauCommunityLocalUserChallengeState, LirauCommunityStateError> {
        if let error = canJoin(challenge: challenge, state: state) {
            return .failure(error)
        }

        return .success(
            LirauCommunityLocalUserChallengeState(
                challengeID: challenge.id,
                role: .joined,
                myEntryID: entryID,
                votedEntryIDs: state.votedEntryIDs,
                updatedAt: now
            )
        )
    }

    static func voteOnlyState(
        for challenge: LirauCommunityChallenge,
        current state: LirauCommunityLocalUserChallengeState,
        now: Date = Date()
    ) -> Result<LirauCommunityLocalUserChallengeState, LirauCommunityStateError> {
        if challenge.phase == .ended {
            return .failure(.challengeEnded)
        }
        if state.role == .joined {
            return .failure(.alreadyJoined)
        }
        if state.role == .host {
            return .failure(.hostCannotParticipate)
        }

        return .success(
            LirauCommunityLocalUserChallengeState(
                challengeID: challenge.id,
                role: .voteOnly,
                myEntryID: state.myEntryID,
                votedEntryIDs: state.votedEntryIDs,
                updatedAt: now
            )
        )
    }

    static func votedState(
        for challenge: LirauCommunityChallenge,
        entryID: String,
        current state: LirauCommunityLocalUserChallengeState,
        profileIntroLorauaCurrentUserID: String,
        now: Date = Date()
    ) -> Result<LirauCommunityLocalUserChallengeState, LirauCommunityStateError> {
        if let error = canVote(
            challenge: challenge,
            entryID: entryID,
            state: state,
            profileIntroLorauaCurrentUserID: profileIntroLorauaCurrentUserID
        ) {
            return .failure(error)
        }

        var nextState = state
        nextState.recordVote(entryID: entryID, now: now)
        return .success(nextState)
    }

    static func canJoin(
        challenge: LirauCommunityChallenge,
        state: LirauCommunityLocalUserChallengeState
    ) -> LirauCommunityStateError? {
        switch challenge.phase {
        case .open:
            break
        case .voting:
            return .submissionsClosed
        case .ended:
            return .challengeEnded
        }

        switch state.role {
        case .none:
            return nil
        case .host:
            return .hostCannotParticipate
        case .joined:
            return .alreadyJoined
        case .voteOnly:
            return .voteOnlyCannotJoin
        }
    }

    static func canVote(
        challenge: LirauCommunityChallenge,
        entryID: String,
        state: LirauCommunityLocalUserChallengeState,
        profileIntroLorauaCurrentUserID: String
    ) -> LirauCommunityStateError? {
        if challenge.phase == .ended {
            return .challengeEnded
        }
        if state.role == .host {
            return .hostCannotParticipate
        }
        guard let entry = challenge.entries.first(where: { $0.id == entryID }) else {
            return .entryNotFound
        }
        if state.votedEntryIDs.contains(entryID) {
            return .duplicateVote
        }
        if entry.userID == profileIntroLorauaCurrentUserID || state.myEntryID == entryID {
            return .cannotVoteOwnEntry
        }
        return nil
    }
}
