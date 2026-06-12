import UIKit

enum LirauCommunityMockData {
    static func seedChallenges(now: Date = Date()) -> [LirauCommunityChallenge] {
        [
            makeChallenge(
                id: "challenge_mood_spanish",
                title: "Today's Mood in Spanish",
                language: "Spanish",
                subtitle: "Share how you feel in one sentence.",
                prompt: "Write one sentence in Spanish that describes your mood today.",
                hostName: "Lucia M.",
                hostUserID: "community_lucia_host",
                coverAssetName: "lira_community_challenge_speak_daily",
                phase: .open,
                durationLabel: "Ends in 12h",
                endsAt: now.addingTimeInterval(12 * 3600),
                joinedCount: 16,
                baseVoteCount: 3,
                likeCount: 12,
                commentCount: 6,
                isHotPinned: true,
                rules: [
                    "Write one public sentence in Spanish.",
                    "Add an English meaning so new learners can follow.",
                    "Vote for entries that feel natural and culturally clear."
                ],
                entries: [
                    makeEntry(id: "entry_mood_lucia", challengeID: "challenge_mood_spanish", userID: "community_lucia", userName: "Lucia", sentence: "Hoy me siento como un cafe con leche en la manana.", translation: "Today I feel like a morning coffee with milk.", accentNote: "Spanish - Mexico", voteCount: 8, likeCount: 9, commentCount: 3, colorHex: "#FF7A6D", createdAt: now.addingTimeInterval(-5200)),
                    makeEntry(id: "entry_mood_marco", challengeID: "challenge_mood_spanish", userID: "community_marco", userName: "Marco", sentence: "Me siento tranquilo, como un dia de domingo.", translation: "I feel calm, like a Sunday.", accentNote: "Spanish - Colombia", voteCount: 6, likeCount: 7, commentCount: 2, colorHex: "#58D8E8", createdAt: now.addingTimeInterval(-4100)),
                    makeEntry(id: "entry_mood_aiko", challengeID: "challenge_mood_spanish", userID: "community_aiko", userName: "Aiko", sentence: "Estoy un poco nerviosa, pero lista para hablar.", translation: "I am a little nervous, but ready to speak.", accentNote: "Spanish learner - Japan", voteCount: 4, likeCount: 5, commentCount: 1, colorHex: "#B846FF", createdAt: now.addingTimeInterval(-2600)),
                    makeEntry(id: "entry_mood_hana", challengeID: "challenge_mood_spanish", userID: "community_hana", userName: "Hana", sentence: "Hoy tengo energia para intentar otra vez.", translation: "Today I have energy to try again.", accentNote: "Spanish learner - Korea", voteCount: 3, likeCount: 3, commentCount: 1, colorHex: "#FFD64D", createdAt: now.addingTimeInterval(-1800))
                ],
                comments: [
                    makeComment(id: "comment_mood_1", userName: "Nina", message: "The coffee sentence feels warm and easy to remember.", createdAt: now.addingTimeInterval(-2200)),
                    makeComment(id: "comment_mood_2", userName: "Mateo", message: "I like seeing mood words in real context.", createdAt: now.addingTimeInterval(-1600))
                ],
                createdAt: now.addingTimeInterval(-9000)
            ),
            makeChallenge(
                id: "challenge_weekend_french",
                title: "Weekend Plan in French",
                language: "French",
                subtitle: "Tell us your weekend, en francais.",
                prompt: "Write one sentence about your weekend plan in French.",
                hostName: "Camille Voice Lab",
                hostUserID: "community_camille_host",
                coverAssetName: "lira_community_challenge_chat",
                phase: .voting,
                durationLabel: "Voting ends in 18h",
                endsAt: now.addingTimeInterval(18 * 3600),
                joinedCount: 12,
                baseVoteCount: 2,
                likeCount: 9,
                commentCount: 5,
                isHotPinned: false,
                rules: [
                    "Submissions are closed during voting.",
                    "Vote for plans that sound friendly and natural.",
                    "One learner can vote for each entry once."
                ],
                entries: [
                    makeEntry(id: "entry_weekend_camille", challengeID: "challenge_weekend_french", userID: "community_camille", userName: "Camille", sentence: "Je veux marcher pres de la riviere ce week-end.", translation: "I want to walk near the river this weekend.", accentNote: "French - Lyon", voteCount: 7, likeCount: 6, commentCount: 2, colorHex: "#60E6A8", createdAt: now.addingTimeInterval(-8300)),
                    makeEntry(id: "entry_weekend_hugo", challengeID: "challenge_weekend_french", userID: "community_hugo", userName: "Hugo", sentence: "Samedi, je vais cuisiner avec ma soeur.", translation: "On Saturday, I will cook with my sister.", accentNote: "French - Marseille", voteCount: 5, likeCount: 5, commentCount: 2, colorHex: "#4ED6FF", createdAt: now.addingTimeInterval(-6900)),
                    makeEntry(id: "entry_weekend_nina", challengeID: "challenge_weekend_french", userID: "community_nina", userName: "Nina", sentence: "Dimanche, je vais lire dans un petit cafe.", translation: "On Sunday, I will read in a small cafe.", accentNote: "French learner - Korea", voteCount: 4, likeCount: 4, commentCount: 1, colorHex: "#FFD64D", createdAt: now.addingTimeInterval(-5400))
                ],
                comments: [
                    makeComment(id: "comment_weekend_1", userName: "Sora", message: "These plans are short enough to copy and practice.", createdAt: now.addingTimeInterval(-3000)),
                    makeComment(id: "comment_weekend_2", userName: "Lucia", message: "I voted for the sentence I would actually say.", createdAt: now.addingTimeInterval(-1900))
                ],
                createdAt: now.addingTimeInterval(-15400)
            ),
            makeChallenge(
                id: "challenge_food_japanese",
                title: "Favorite Food in Japanese",
                language: "Japanese",
                subtitle: "Describe your favorite food.",
                prompt: "Share one Japanese sentence about food you want to eat.",
                hostName: "Aiko Table Talk",
                hostUserID: "community_aiko_host",
                coverAssetName: "lira_community_challenge_reading",
                phase: .ended,
                durationLabel: "Ended",
                endsAt: now.addingTimeInterval(-5 * 3600),
                joinedCount: 18,
                baseVoteCount: 3,
                likeCount: 14,
                commentCount: 6,
                isHotPinned: true,
                rules: [
                    "Keep the sentence short and food-focused.",
                    "Add an English meaning.",
                    "Results are based on usefulness for everyday conversation."
                ],
                entries: [
                    makeEntry(id: "entry_food_aiko", challengeID: "challenge_food_japanese", userID: "community_aiko", userName: "Aiko", sentence: "今日はカレーが食べたいです。", translation: "I want to eat curry today.", accentNote: "Japanese - Tokyo", voteCount: 9, likeCount: 8, commentCount: 3, colorHex: "#B846FF", createdAt: now.addingTimeInterval(-18500)),
                    makeEntry(id: "entry_food_ken", challengeID: "challenge_food_japanese", userID: "community_ken", userName: "Ken", sentence: "朝ごはんに味噌汁を飲みたいです。", translation: "I want miso soup for breakfast.", accentNote: "Japanese - Osaka", voteCount: 7, likeCount: 6, commentCount: 2, colorHex: "#4ED6FF", createdAt: now.addingTimeInterval(-17400)),
                    makeEntry(id: "entry_food_maya", challengeID: "challenge_food_japanese", userID: "community_maya", userName: "Maya", sentence: "甘いパンが好きです。", translation: "I like sweet bread.", accentNote: "Japanese learner - Canada", voteCount: 5, likeCount: 5, commentCount: 1, colorHex: "#FF7A9C", createdAt: now.addingTimeInterval(-16000))
                ],
                comments: [
                    makeComment(id: "comment_food_1", userName: "Marco", message: "Food phrases are the easiest way to start a chat.", createdAt: now.addingTimeInterval(-7200)),
                    makeComment(id: "comment_food_2", userName: "Hana", message: "The curry sentence was simple and useful.", createdAt: now.addingTimeInterval(-5100))
                ],
                createdAt: now.addingTimeInterval(-26000)
            ),
            makeChallenge(
                id: "challenge_pronunciation_boost",
                title: "Pronunciation Boost",
                language: "English",
                subtitle: "Practice one tricky sound.",
                prompt: "Share a short sentence that helps you practice a sound.",
                hostName: "Hana Sound Desk",
                hostUserID: "community_hana_host",
                coverAssetName: "lira_community_challenge_pronunciation",
                phase: .voting,
                durationLabel: "Voting now",
                endsAt: now.addingTimeInterval(9 * 3600),
                joinedCount: 15,
                baseVoteCount: 2,
                likeCount: 13,
                commentCount: 5,
                isHotPinned: true,
                rules: [
                    "Pick one sound or rhythm pattern.",
                    "Respect every learner's accent.",
                    "Vote for entries that are easy to repeat."
                ],
                entries: [
                    makeEntry(id: "entry_pron_aiko", challengeID: "challenge_pronunciation_boost", userID: "community_aiko", userName: "Aiko", sentence: "Light rain rolls over the road.", translation: "A line for practicing r and l.", accentNote: "English learner - Japan", voteCount: 8, likeCount: 7, commentCount: 2, colorHex: "#B846FF", createdAt: now.addingTimeInterval(-6400)),
                    makeEntry(id: "entry_pron_ines", challengeID: "challenge_pronunciation_boost", userID: "community_ines", userName: "Ines", sentence: "Three thin things sit there.", translation: "A short th sound practice line.", accentNote: "English learner - Chile", voteCount: 6, likeCount: 6, commentCount: 2, colorHex: "#60E6A8", createdAt: now.addingTimeInterval(-5200)),
                    makeEntry(id: "entry_pron_omar", challengeID: "challenge_pronunciation_boost", userID: "community_omar", userName: "Omar", sentence: "Very warm words work well.", translation: "A gentle w and v practice phrase.", accentNote: "English learner - Morocco", voteCount: 4, likeCount: 4, commentCount: 1, colorHex: "#FF9C5E", createdAt: now.addingTimeInterval(-4100))
                ],
                comments: [
                    makeComment(id: "comment_pron_1", userName: "Hugo", message: "The r and l sentence is hard but memorable.", createdAt: now.addingTimeInterval(-3000)),
                    makeComment(id: "comment_pron_2", userName: "Maya", message: "Accent notes make the votes more fair.", createdAt: now.addingTimeInterval(-1400))
                ],
                createdAt: now.addingTimeInterval(-35000)
            ),
            makeChallenge(
                id: "challenge_daily_writing",
                title: "Daily Writing",
                language: "German",
                subtitle: "Write a few sentences every day.",
                prompt: "Write two short sentences about your day in a language you are learning.",
                hostName: "Lena Journal",
                hostUserID: "community_lena_host",
                coverAssetName: "lira_community_challenge_daily_writing",
                phase: .open,
                durationLabel: "Ends in 3d",
                endsAt: now.addingTimeInterval(3 * 24 * 3600),
                joinedCount: 10,
                baseVoteCount: 1,
                likeCount: 8,
                commentCount: 4,
                isHotPinned: false,
                rules: [
                    "Write two short sentences.",
                    "Include one detail from real daily life.",
                    "Corrections should be gentle and specific."
                ],
                entries: [
                    makeEntry(id: "entry_write_lena", challengeID: "challenge_daily_writing", userID: "community_lena", userName: "Lena", sentence: "Heute lerne ich im Cafe. Danach rufe ich meine Freundin an.", translation: "Today I study in a cafe. After that I call my friend.", accentNote: "German learner - US", voteCount: 5, likeCount: 4, commentCount: 2, colorHex: "#FFD64D", createdAt: now.addingTimeInterval(-7200)),
                    makeEntry(id: "entry_write_camille", challengeID: "challenge_daily_writing", userID: "community_camille", userName: "Camille", sentence: "Ich schreibe langsam, aber mit mehr Vertrauen.", translation: "I write slowly, but with more confidence.", accentNote: "German learner - France", voteCount: 4, likeCount: 3, commentCount: 1, colorHex: "#B846FF", createdAt: now.addingTimeInterval(-5000)),
                    makeEntry(id: "entry_write_sora", challengeID: "challenge_daily_writing", userID: "community_sora", userName: "Sora", sentence: "Mein Tag war ruhig. Ich habe neue Worter gelernt.", translation: "My day was quiet. I learned new words.", accentNote: "German learner - Japan", voteCount: 3, likeCount: 2, commentCount: 1, colorHex: "#4ED6FF", createdAt: now.addingTimeInterval(-3900))
                ],
                comments: [
                    makeComment(id: "comment_write_1", userName: "Sora", message: "Two sentences is a good size for daily practice.", createdAt: now.addingTimeInterval(-3300)),
                    makeComment(id: "comment_write_2", userName: "Marco", message: "I want this one to run every week.", createdAt: now.addingTimeInterval(-1700))
                ],
                createdAt: now.addingTimeInterval(-43000)
            ),
            makeChallenge(
                id: "challenge_study_together",
                title: "Study Together",
                language: "Multi-language",
                subtitle: "Complete a language task with a partner.",
                prompt: "Share one safe language task you can complete with a study partner today.",
                hostName: "LiraU Peer Circle",
                hostUserID: "community_peer_host",
                coverAssetName: "lira_community_challenge_study_together",
                phase: .open,
                durationLabel: "Ends in 7d",
                endsAt: now.addingTimeInterval(7 * 24 * 3600),
                joinedCount: 22,
                baseVoteCount: 3,
                likeCount: 15,
                commentCount: 7,
                isHotPinned: true,
                rules: [
                    "Suggest a partner-friendly language task.",
                    "Keep it safe, public and learning-focused.",
                    "Vote for ideas you would actually try."
                ],
                entries: [
                    makeEntry(id: "entry_together_hugo", challengeID: "challenge_study_together", userID: "community_hugo", userName: "Hugo", sentence: "We can swap five voice notes and correct one phrase each.", translation: "A practical partner task.", accentNote: "French - Lyon", voteCount: 8, likeCount: 7, commentCount: 3, colorHex: "#4ED6FF", createdAt: now.addingTimeInterval(-8800)),
                    makeEntry(id: "entry_together_nina", challengeID: "challenge_study_together", userID: "community_nina", userName: "Nina", sentence: "We can describe our breakfast and ask two follow-up questions.", translation: "A daily-life conversation task.", accentNote: "English learner - Korea", voteCount: 7, likeCount: 6, commentCount: 2, colorHex: "#FFD64D", createdAt: now.addingTimeInterval(-6600)),
                    makeEntry(id: "entry_together_omar", challengeID: "challenge_study_together", userID: "community_omar", userName: "Omar", sentence: "We can read the same short paragraph and explain one new word.", translation: "A shared reading task.", accentNote: "English - Morocco", voteCount: 5, likeCount: 5, commentCount: 1, colorHex: "#B846FF", createdAt: now.addingTimeInterval(-5100)),
                    makeEntry(id: "entry_together_maya", challengeID: "challenge_study_together", userID: "community_maya", userName: "Maya", sentence: "We can teach each other one polite phrase from home.", translation: "A cultural exchange starter.", accentNote: "English - Canada", voteCount: 4, likeCount: 4, commentCount: 1, colorHex: "#FF7A9C", createdAt: now.addingTimeInterval(-3600))
                ],
                comments: [
                    makeComment(id: "comment_together_1", userName: "Lucia", message: "Voice notes make this feel like real conversation.", createdAt: now.addingTimeInterval(-3400)),
                    makeComment(id: "comment_together_2", userName: "Hana", message: "I would try the breakfast question task.", createdAt: now.addingTimeInterval(-2200)),
                    makeComment(id: "comment_together_3", userName: "Camille", message: "The shared reading idea is easy to repeat.", createdAt: now.addingTimeInterval(-800))
                ],
                createdAt: now.addingTimeInterval(-52000)
            )
        ]
    }

    static func makeChallenge(
        id: String,
        title: String,
        language: String,
        subtitle: String,
        prompt: String,
        hostName: String,
        hostUserID: String,
        coverAssetName: String,
        localImageURI: String? = nil,
        phase: LirauCommunityChallengePhase,
        durationLabel: String,
        durationHours: Int? = nil,
        endsAt: Date?,
        joinedCount: Int,
        baseVoteCount: Int,
        likeCount: Int,
        commentCount: Int,
        isHotPinned: Bool = false,
        rules: [String],
        entries: [LirauCommunityEntry],
        comments: [LirauCommunityComment],
        isCreatedByCurrentUser: Bool = false,
        createdAt: Date
    ) -> LirauCommunityChallenge {
        LirauCommunityChallenge(
            id: id,
            title: title,
            language: language,
            subtitle: subtitle,
            prompt: prompt,
            hostName: hostName,
            hostUserID: hostUserID,
            coverAssetName: coverAssetName,
            localImageURI: localImageURI,
            status: phase.legacyStatus,
            durationLabel: durationLabel,
            durationHours: durationHours,
            endsAt: endsAt,
            joinedCount: joinedCount,
            baseVoteCount: baseVoteCount,
            likeCount: likeCount,
            commentCount: max(commentCount, comments.count),
            rules: rules,
            entries: entries,
            comments: comments,
            currentUserMode: .none,
            currentUserEntryID: nil,
            votedEntryID: nil,
            currentUserVotedEntryIDs: nil,
            isLikedByCurrentUser: false,
            isCreatedByCurrentUser: isCreatedByCurrentUser,
            isHotPinned: isHotPinned,
            createdAt: createdAt
        )
    }

    static func makeEntry(
        id: String,
        challengeID: String,
        userID: String,
        userName: String,
        sentence: String,
        translation: String,
        accentNote: String,
        voteCount: Int,
        likeCount: Int,
        commentCount: Int,
        colorHex: String,
        createdAt: Date
    ) -> LirauCommunityEntry {
        LirauCommunityEntry(
            id: id,
            challengeID: challengeID,
            userID: userID,
            userName: userName,
            sentence: sentence,
            translation: translation,
            accentNote: accentNote,
            voteCount: voteCount,
            likeCount: likeCount,
            commentCount: commentCount,
            avatarAssetName: "lira_profile_avatar_default",
            colorHex: colorHex,
            createdAt: createdAt
        )
    }

    static func makeComment(id: String, userName: String, message: String, createdAt: Date) -> LirauCommunityComment {
        LirauCommunityComment(
            id: id,
            userName: userName,
            message: message,
            createdAt: createdAt
        )
    }
}
