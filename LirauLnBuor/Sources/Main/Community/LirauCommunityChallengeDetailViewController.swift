import UIKit

enum LirauCommunityDetailTab {
    case entries
    case rules
}

final class LirauCommunityChallengeDetailViewController: UIViewController {
    private let challengeID: String
    private let store = LirauCommunityLocalStore.shared
    private var selectedTab: LirauCommunityDetailTab = .entries

    private let backgroundView = LirauCommunityBackgroundView()
    private let scrollView = UIScrollView()
    private let contentStack = UIStackView()

    init(challengeID: String) {
        self.challengeID = challengeID
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        buildBase()
        reloadContent()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        reloadContent()
    }

    private func buildBase() {
        view.backgroundColor = LirauCommunityPalette.background
        backgroundView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(backgroundView)

        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.alwaysBounceVertical = true
        scrollView.contentInset.bottom = 44
        scrollView.verticalScrollIndicatorInsets = UIEdgeInsets(top: 0, left: 0, bottom: 44, right: 0)
        view.addSubview(scrollView)

        contentStack.translatesAutoresizingMaskIntoConstraints = false
        contentStack.axis = .vertical
        contentStack.spacing = 16
        contentStack.layoutMargins = UIEdgeInsets(top: 16, left: 18, bottom: 48, right: 18)
        contentStack.isLayoutMarginsRelativeArrangement = true
        scrollView.addSubview(contentStack)

        NSLayoutConstraint.activate([
            backgroundView.topAnchor.constraint(equalTo: view.topAnchor),
            backgroundView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            backgroundView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            backgroundView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            contentStack.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            contentStack.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
            contentStack.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),
            contentStack.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
            contentStack.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor)
        ])
    }

    private func reloadContent() {
        contentStack.removeAllArrangedSubviews()
        guard let challenge = challengeForDisplay() else {
            contentStack.addArrangedSubview(makeNavigationRow(title: "Challenge"))
            contentStack.addArrangedSubview(LirauCommunityEmptyStateView(message: "Challenge data is unavailable."))
            return
        }

        contentStack.addArrangedSubview(makeNavigationRow(title: "Challenge"))
        contentStack.addArrangedSubview(makeHeroCard(challenge))
        contentStack.addArrangedSubview(makeStatePanel(challenge))
        contentStack.addArrangedSubview(makeSegmentedTabs())
        switch selectedTab {
        case .entries:
            contentStack.addArrangedSubview(makeEntryList(challenge))
        case .rules:
            contentStack.addArrangedSubview(makeRulesList(challenge.rules))
        }
    }

    private func challengeForDisplay() -> LirauCommunityChallenge? {
        guard let challenge = store.challenge(with: challengeID) else { return nil }
        guard challenge.phase == .voting, challenge.currentUserMode == .none else {
            return challenge
        }

        switch store.voteOnly(challengeID: challengeID) {
        case .success(let updatedChallenge):
            return updatedChallenge
        case .failure:
            return challenge
        }
    }

    private func makeNavigationRow(title: String) -> UIView {
        let row = UIStackView()
        row.axis = .horizontal
        row.alignment = .center
        row.spacing = 12

        let backButton = LirauCommunityIconButton(systemName: "chevron.left")
        backButton.addTarget(self, action: #selector(closePage), for: .touchUpInside)

        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = .systemFont(ofSize: 18, weight: .bold)
        titleLabel.textColor = .white

        let moreButton = LirauCommunityIconButton(systemName: "ellipsis")
        moreButton.addTarget(self, action: #selector(reportChallenge), for: .touchUpInside)

        row.addArrangedSubview(backButton)
        row.addArrangedSubview(titleLabel)
        row.addArrangedSubview(UIView())
        row.addArrangedSubview(moreButton)

        NSLayoutConstraint.activate([
            backButton.widthAnchor.constraint(equalToConstant: 36),
            backButton.heightAnchor.constraint(equalToConstant: 36),
            moreButton.widthAnchor.constraint(equalToConstant: 36),
            moreButton.heightAnchor.constraint(equalToConstant: 36)
        ])
        return row
    }

    private func makeHeroCard(_ challenge: LirauCommunityChallenge) -> UIView {
        let card = UIView()
        card.applyLirauCommunityChrome(cornerRadius: 24, borderAlpha: 0.1, shadowAlpha: 0.18)

        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.spacing = 13
        stack.layoutMargins = UIEdgeInsets(top: 12, left: 12, bottom: 14, right: 12)
        stack.isLayoutMarginsRelativeArrangement = true
        card.addSubview(stack)

        let coverContainer = UIView()
        coverContainer.layer.cornerRadius = 18
        coverContainer.clipsToBounds = true
        coverContainer.backgroundColor = LirauCommunityPalette.elevated
        let imageView = UIImageView(image: challenge.displayCoverImage)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        coverContainer.addSubview(imageView)
        let statusPill = LirauCommunityStatusPill(status: challenge.status)
        statusPill.translatesAutoresizingMaskIntoConstraints = false
        coverContainer.addSubview(statusPill)

        let durationBadge = UILabel()
        durationBadge.translatesAutoresizingMaskIntoConstraints = false
        durationBadge.text = challenge.durationLabel
        durationBadge.textAlignment = .center
        durationBadge.textColor = .white
        durationBadge.font = .systemFont(ofSize: 11, weight: .bold)
        durationBadge.backgroundColor = UIColor.black.withAlphaComponent(0.46)
        durationBadge.layer.cornerRadius = 12
        durationBadge.clipsToBounds = true
        coverContainer.addSubview(durationBadge)

        let titleLabel = UILabel()
        titleLabel.text = challenge.title
        titleLabel.font = .systemFont(ofSize: 19, weight: .bold)
        titleLabel.textColor = .white
        titleLabel.numberOfLines = 2

        let promptLabel = UILabel()
        promptLabel.text = challenge.prompt
        promptLabel.font = .systemFont(ofSize: 13, weight: .medium)
        promptLabel.textColor = LirauCommunityPalette.mutedText
        promptLabel.numberOfLines = 0

        let metaLabel = UILabel()
        metaLabel.text = "Host \(challenge.hostName)  •  \(challenge.participantText)  •  \(challenge.voteText)"
        metaLabel.font = .systemFont(ofSize: 12, weight: .semibold)
        metaLabel.textColor = LirauCommunityPalette.dimText
        metaLabel.numberOfLines = 0

        stack.addArrangedSubview(coverContainer)
        stack.addArrangedSubview(titleLabel)
        stack.addArrangedSubview(promptLabel)
        stack.addArrangedSubview(metaLabel)

        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: card.topAnchor),
            stack.leadingAnchor.constraint(equalTo: card.leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: card.trailingAnchor),
            stack.bottomAnchor.constraint(equalTo: card.bottomAnchor),
            coverContainer.heightAnchor.constraint(equalToConstant: 172),
            imageView.topAnchor.constraint(equalTo: coverContainer.topAnchor),
            imageView.leadingAnchor.constraint(equalTo: coverContainer.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: coverContainer.trailingAnchor),
            imageView.bottomAnchor.constraint(equalTo: coverContainer.bottomAnchor),
            statusPill.topAnchor.constraint(equalTo: coverContainer.topAnchor, constant: 12),
            statusPill.leadingAnchor.constraint(equalTo: coverContainer.leadingAnchor, constant: 12),
            statusPill.heightAnchor.constraint(equalToConstant: 24),
            statusPill.widthAnchor.constraint(greaterThanOrEqualToConstant: 62),
            durationBadge.topAnchor.constraint(equalTo: coverContainer.topAnchor, constant: 12),
            durationBadge.trailingAnchor.constraint(equalTo: coverContainer.trailingAnchor, constant: -12),
            durationBadge.heightAnchor.constraint(equalToConstant: 24),
            durationBadge.widthAnchor.constraint(greaterThanOrEqualToConstant: 78)
        ])
        return card
    }

    private func makeStatePanel(_ challenge: LirauCommunityChallenge) -> UIView {
        let panel = UIView()
        panel.applyLirauCommunityChrome(backgroundColor: LirauCommunityPalette.surface, cornerRadius: 20, borderAlpha: 0.08, shadowAlpha: 0.12)

        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.spacing = 10
        stack.layoutMargins = UIEdgeInsets(top: 14, left: 14, bottom: 14, right: 14)
        stack.isLayoutMarginsRelativeArrangement = true
        panel.addSubview(stack)

        let stateLabel = UILabel()
        stateLabel.font = .systemFont(ofSize: 13, weight: .semibold)
        stateLabel.textColor = LirauCommunityPalette.mutedText
        stateLabel.numberOfLines = 0

        let buttonRow = UIStackView()
        buttonRow.axis = .horizontal
        buttonRow.spacing = 10
        buttonRow.distribution = .fillEqually

        if challenge.currentUserMode == .host {
            stateLabel.text = "You're hosting this challenge\nHosts can view entries but can't submit or vote."
            let shareButton = makeSecondaryButton(title: "Share")
            shareButton.addTarget(self, action: #selector(shareChallenge), for: .touchUpInside)
            buttonRow.addArrangedSubview(shareButton)
        } else if challenge.phase == .ended {
            stateLabel.text = "This challenge has ended. Review the final ranking and keep practicing with the next one."
            let resultButton = LirauCommunityGradientButton(type: .system)
            resultButton.setTitle("See Results", for: .normal)
            resultButton.addTarget(self, action: #selector(openResults), for: .touchUpInside)
            buttonRow.addArrangedSubview(resultButton)
        } else if challenge.phase == .voting {
            stateLabel.text = "Submissions closed. You're voting in this challenge now - choose the entries that teach useful language or cultural nuance."
            let voteOnlyButton = makeSecondaryButton(title: challenge.recordedVotedEntryIDs.isEmpty ? "Vote below" : "Voting")
            voteOnlyButton.isEnabled = false
            buttonRow.addArrangedSubview(voteOnlyButton)
        } else if challenge.currentUserMode == .submitted {
            stateLabel.text = "You've joined — wait for votes. Your entry is highlighted below, and you can still vote for other learners."
            let shareButton = makeSecondaryButton(title: "Share")
            shareButton.addTarget(self, action: #selector(shareChallenge), for: .touchUpInside)
            buttonRow.addArrangedSubview(shareButton)
        } else if challenge.currentUserMode == .voteOnly {
            stateLabel.text = "You're voting in this challenge. Vote for entries that are clear, friendly and useful for real conversation."
            let voteButton = makeSecondaryButton(title: challenge.recordedVotedEntryIDs.isEmpty ? "Vote below" : "Voting")
            voteButton.isEnabled = false
            buttonRow.addArrangedSubview(voteButton)
        } else {
            stateLabel.text = "Choose a role for this challenge. Join with your own phrase, or vote only."
            let joinButton = LirauCommunityGradientButton(type: .system)
            joinButton.setTitle("+ Join Challenge", for: .normal)
            joinButton.addTarget(self, action: #selector(joinChallenge), for: .touchUpInside)
            let voteButton = makeSecondaryButton(title: "Vote Only")
            voteButton.addTarget(self, action: #selector(voteOnly), for: .touchUpInside)
            buttonRow.addArrangedSubview(joinButton)
            buttonRow.addArrangedSubview(voteButton)
        }

        stack.addArrangedSubview(stateLabel)
        if !buttonRow.arrangedSubviews.isEmpty {
            stack.addArrangedSubview(buttonRow)
            buttonRow.arrangedSubviews.forEach { view in
                view.heightAnchor.constraint(equalToConstant: 42).isActive = true
            }
        }

        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: panel.topAnchor),
            stack.leadingAnchor.constraint(equalTo: panel.leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: panel.trailingAnchor),
            stack.bottomAnchor.constraint(equalTo: panel.bottomAnchor)
        ])
        return panel
    }

    private func makeSegmentedTabs() -> UIView {
        let container = UIView()
        container.backgroundColor = UIColor.white.withAlphaComponent(0.055)
        container.layer.cornerRadius = 14
        container.layer.borderWidth = 1
        container.layer.borderColor = UIColor.white.withAlphaComponent(0.07).cgColor

        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .horizontal
        stack.spacing = 6
        stack.distribution = .fillEqually
        stack.layoutMargins = UIEdgeInsets(top: 4, left: 4, bottom: 4, right: 4)
        stack.isLayoutMarginsRelativeArrangement = true
        container.addSubview(stack)

        let entriesButton = makeTabButton(title: "Entries", isSelected: selectedTab == .entries)
        entriesButton.addTarget(self, action: #selector(showEntries), for: .touchUpInside)
        let rulesButton = makeTabButton(title: "Rules", isSelected: selectedTab == .rules)
        rulesButton.addTarget(self, action: #selector(showRules), for: .touchUpInside)
        stack.addArrangedSubview(entriesButton)
        stack.addArrangedSubview(rulesButton)

        NSLayoutConstraint.activate([
            container.heightAnchor.constraint(equalToConstant: 48),
            stack.topAnchor.constraint(equalTo: container.topAnchor),
            stack.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            stack.bottomAnchor.constraint(equalTo: container.bottomAnchor)
        ])
        return container
    }

    private func makeEntryList(_ challenge: LirauCommunityChallenge) -> UIView {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 12

        if challenge.entries.isEmpty {
            if challenge.currentUserMode == .host {
                stack.addArrangedSubview(
                    LirauCommunityEmptyStateView(
                        message: "No entries yet\nShare your challenge and wait for learners to join."
                    )
                )
            } else {
                stack.addArrangedSubview(LirauCommunityEmptyStateView(message: "No entries yet. Be the first learner to join."))
            }
            return stack
        }

        let currentUser = LirauCommunityUserSnapshot.current
        if challenge.phase == .ended {
            stack.addArrangedSubview(makeWinnerPanel(challenge))
        }

        sortedEntries(for: challenge, currentUserID: currentUser.userID).forEach { entry in
            let card = LirauCommunityEntryCardView()
            card.configure(entry: entry, challenge: challenge, currentUserID: currentUser.userID)
            card.onVote = { [weak self] in self?.vote(for: entry) }
            card.onReport = { [weak self] in self?.showReportNotice(target: entry.userName) }
            card.onProfile = { [weak self] in self?.openLearnerProfile(entry.userID) }
            stack.addArrangedSubview(card)
        }
        stack.addArrangedSubview(makeCommentPreview(challenge))
        return stack
    }

    private func sortedEntries(for challenge: LirauCommunityChallenge, currentUserID: String) -> [LirauCommunityEntry] {
        if challenge.phase == .ended {
            return challenge.entries.sorted {
                if $0.voteCount == $1.voteCount {
                    return $0.createdAt < $1.createdAt
                }
                return $0.voteCount > $1.voteCount
            }
        }

        guard let currentUserEntryID = challenge.currentUserEntryID else {
            return challenge.entries
        }
        return challenge.entries.sorted {
            if $0.id == currentUserEntryID { return true }
            if $1.id == currentUserEntryID { return false }
            return $0.createdAt > $1.createdAt
        }
    }

    private func makeWinnerPanel(_ challenge: LirauCommunityChallenge) -> UIView {
        let sorted = sortedEntries(for: challenge, currentUserID: LirauCommunityUserSnapshot.current.userID)
        let container = UIView()
        container.applyLirauCommunityChrome(
            backgroundColor: LirauCommunityPalette.elevated.withAlphaComponent(0.92),
            cornerRadius: 20,
            borderAlpha: 0.08,
            shadowAlpha: 0.12
        )
        container.layer.borderColor = LirauCommunityPalette.purpleLight.withAlphaComponent(0.28).cgColor

        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.spacing = 10
        stack.layoutMargins = UIEdgeInsets(top: 14, left: 14, bottom: 14, right: 14)
        stack.isLayoutMarginsRelativeArrangement = true
        container.addSubview(stack)

        let titleLabel = UILabel()
        titleLabel.text = "Winner / Top entries"
        titleLabel.textColor = .white
        titleLabel.font = .systemFont(ofSize: 15, weight: .bold)
        stack.addArrangedSubview(titleLabel)

        if let winner = sorted.first {
            let winnerLabel = UILabel()
            winnerLabel.text = "Winner: \(winner.userName) - \(winner.voteCount) votes"
            winnerLabel.textColor = LirauCommunityPalette.purpleLight
            winnerLabel.font = .systemFont(ofSize: 13, weight: .bold)
            winnerLabel.numberOfLines = 0
            stack.addArrangedSubview(winnerLabel)
        }

        sorted.prefix(3).enumerated().forEach { index, entry in
            let row = UILabel()
            row.text = "#\(index + 1) \(entry.userName): \(entry.sentence)"
            row.textColor = LirauCommunityPalette.mutedText
            row.font = .systemFont(ofSize: 12, weight: .semibold)
            row.numberOfLines = 0
            stack.addArrangedSubview(row)
        }

        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: container.topAnchor),
            stack.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            stack.bottomAnchor.constraint(equalTo: container.bottomAnchor)
        ])
        return container
    }

    private func makeCommentPreview(_ challenge: LirauCommunityChallenge) -> UIView {
        let container = UIView()
        container.applyLirauCommunityChrome(
            backgroundColor: LirauCommunityPalette.surface.withAlphaComponent(0.94),
            cornerRadius: 20,
            borderAlpha: 0.08,
            shadowAlpha: 0.1
        )

        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.spacing = 10
        stack.layoutMargins = UIEdgeInsets(top: 14, left: 14, bottom: 14, right: 14)
        stack.isLayoutMarginsRelativeArrangement = true
        container.addSubview(stack)

        let titleLabel = UILabel()
        titleLabel.text = "Learner comments  \(challenge.commentCount)"
        titleLabel.font = .systemFont(ofSize: 14, weight: .bold)
        titleLabel.textColor = .white
        stack.addArrangedSubview(titleLabel)

        if challenge.comments.isEmpty {
            let emptyLabel = UILabel()
            emptyLabel.text = "No comments yet. Join the challenge to start the conversation."
            emptyLabel.font = .systemFont(ofSize: 12, weight: .medium)
            emptyLabel.textColor = LirauCommunityPalette.mutedText
            emptyLabel.numberOfLines = 0
            stack.addArrangedSubview(emptyLabel)
        } else {
            challenge.comments.prefix(3).forEach { comment in
                let label = UILabel()
                label.text = "\(comment.userName): \(comment.message)"
                label.font = .systemFont(ofSize: 12, weight: .medium)
                label.textColor = LirauCommunityPalette.mutedText
                label.numberOfLines = 0
                stack.addArrangedSubview(label)
            }
        }

        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: container.topAnchor),
            stack.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            stack.bottomAnchor.constraint(equalTo: container.bottomAnchor)
        ])
        return container
    }

    private func makeRulesList(_ rules: [String]) -> UIView {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 10
        let displayRules = rules + [
            "Voters can't submit an entry after choosing vote-only mode.",
            "One vote per user per entry.",
            "Voting helps decide the winners."
        ]
        displayRules.enumerated().forEach { index, rule in
            let label = UILabel()
            label.text = "\(index + 1). \(rule)"
            label.font = .systemFont(ofSize: 13, weight: .medium)
            label.textColor = LirauCommunityPalette.mutedText
            label.numberOfLines = 0
            label.backgroundColor = UIColor.white.withAlphaComponent(0.06)
            label.layer.cornerRadius = 14
            label.clipsToBounds = true
            label.setContentCompressionResistancePriority(.required, for: .vertical)

            let wrapper = UIView()
            wrapper.backgroundColor = LirauCommunityPalette.surface.withAlphaComponent(0.92)
            wrapper.layer.cornerRadius = 16
            wrapper.layer.borderWidth = 1
            wrapper.layer.borderColor = UIColor.white.withAlphaComponent(0.07).cgColor
            label.translatesAutoresizingMaskIntoConstraints = false
            wrapper.addSubview(label)
            NSLayoutConstraint.activate([
                label.topAnchor.constraint(equalTo: wrapper.topAnchor, constant: 12),
                label.leadingAnchor.constraint(equalTo: wrapper.leadingAnchor, constant: 14),
                label.trailingAnchor.constraint(equalTo: wrapper.trailingAnchor, constant: -14),
                label.bottomAnchor.constraint(equalTo: wrapper.bottomAnchor, constant: -12)
            ])
            stack.addArrangedSubview(wrapper)
        }
        return stack
    }

    private func makeSecondaryButton(title: String) -> UIButton {
        let button = UIButton(type: .system)
        button.layer.cornerRadius = 18
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.white.withAlphaComponent(0.1).cgColor
        button.backgroundColor = UIColor.white.withAlphaComponent(0.095)
        button.setTitle(title, for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 14, weight: .bold)
        return button
    }

    private func makeTabButton(title: String, isSelected: Bool) -> UIButton {
        let button = UIButton(type: .system)
        button.layer.cornerRadius = 12
        button.backgroundColor = isSelected ? LirauCommunityPalette.purpleSoft : .clear
        button.setTitle(title, for: .normal)
        button.setTitleColor(isSelected ? .white : LirauCommunityPalette.mutedText, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 13, weight: .semibold)
        return button
    }

    @objc private func closePage() {
        navigationController?.popViewController(animated: true)
    }

    @objc private func reportChallenge() {
        guard let challenge = store.challenge(with: challengeID) else { return }
        let alert = UIAlertController(title: challenge.title, message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Share challenge", style: .default) { [weak self] _ in
            self?.presentShareSheet(items: ["Join my LiraU language challenge: \(challenge.title)"])
        })
        alert.addAction(UIAlertAction(title: "Report challenge", style: .destructive) { [weak self] _ in
            self?.showReportNotice(target: challenge.title)
        })
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        if let popover = alert.popoverPresentationController {
            popover.sourceView = view
            popover.sourceRect = CGRect(x: view.bounds.maxX - 48, y: view.safeAreaInsets.top + 24, width: 1, height: 1)
        }
        present(alert, animated: true)
    }

    @objc private func joinChallenge() {
        guard let challenge = store.challenge(with: challengeID) else { return }
        guard challenge.phase == .open else {
            showToast(challenge.phase == .voting ? "Submissions closed." : "This challenge has ended.")
            return
        }

        switch challenge.currentUserMode {
        case .none:
            let controller = LirauCommunitySubmitEntryViewController(challengeID: challengeID)
            controller.onSubmitted = { [weak self] in
                self?.selectedTab = .entries
            }
            navigationController?.pushViewController(controller, animated: true)
        case .host:
            showToast("Hosts can view entries but can't submit or vote.")
        case .submitted:
            showToast("You've already joined this challenge.")
        case .voteOnly:
            showToast("You already chose vote-only mode.")
        }
    }

    @objc private func voteOnly() {
        switch store.voteOnly(challengeID: challengeID) {
        case .success:
            NSLog("LiraU Community vote-only selected: %@", challengeID)
            showToast("You're voting in this challenge.")
            reloadContent()
        case .failure(let error):
            showToast(error.localizedDescription)
        }
    }

    @objc private func openResults() {
        let controller = LirauCommunityResultViewController(challengeID: challengeID)
        navigationController?.pushViewController(controller, animated: true)
    }

    @objc private func shareChallenge() {
        guard let challenge = store.challenge(with: challengeID) else { return }
        presentShareSheet(items: ["Join my LiraU language challenge: \(challenge.title)"])
    }

    @objc private func showEntries() {
        selectedTab = .entries
        reloadContent()
    }

    @objc private func showRules() {
        selectedTab = .rules
        reloadContent()
    }

    private func vote(for entry: LirauCommunityEntry) {
        guard let challenge = store.challenge(with: challengeID) else { return }
        let currentUser = LirauCommunityUserSnapshot.current
        if challenge.currentUserMode == .host || challenge.hostUserID == currentUser.userID {
            showToast("Hosts can view entries but can't submit or vote.")
            return
        }
        if challenge.phase == .ended {
            showToast("Voting has ended.")
            return
        }
        if entry.userID == currentUser.userID {
            showToast("You cannot vote for your own entry.")
            return
        }
        if challenge.recordedVotedEntryIDs.contains(entry.id) {
            showToast("You already voted for this entry.")
            return
        }
        switch store.voteEntry(challengeID: challengeID, entryID: entry.id) {
        case .success:
            NSLog("LiraU Community vote: %@", entry.id)
            showToast("Vote recorded.")
            reloadContent()
        case .failure(let error):
            showToast(error.localizedDescription)
        }
    }

    private func openLearnerProfile(_ userID: String) {
        let controller = LirauWebPortalViewController(entryURLString: LirauWebRoute.learnerProfilePath(userID: userID))
        controller.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(controller, animated: true)
    }
}

final class LirauCommunityEntryCardView: UIView {
    var onVote: (() -> Void)?
    var onReport: (() -> Void)?
    var onProfile: (() -> Void)?

    private let avatarView = UIImageView()
    private let nameButton = UIButton(type: .system)
    private let ownBadgeLabel = UILabel()
    private let accentLabel = UILabel()
    private let sentenceLabel = UILabel()
    private let translationLabel = UILabel()
    private let entryMetricsLabel = UILabel()
    private let voteButton = LirauCommunityGradientButton(type: .system)
    private let reportButton = UIButton(type: .system)

    override init(frame: CGRect) {
        super.init(frame: frame)
        buildCard()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(entry: LirauCommunityEntry, challenge: LirauCommunityChallenge, currentUserID: String) {
        avatarView.image = nil
        avatarView.backgroundColor = UIColor(lirauHex: entry.colorHex)
        nameButton.setTitle(entry.userName, for: .normal)
        accentLabel.text = "\(entry.accentNote)  •  \(LirauCommunityFormatter.relativeTime(entry.createdAt))"
        sentenceLabel.text = entry.sentence
        translationLabel.text = entry.translation
        entryMetricsLabel.text = "\(entry.voteCount) votes  ·  \(entry.likeCount) likes  ·  \(entry.commentCount) comments"

        let isOwnEntry = entry.userID == currentUserID || challenge.currentUserEntryID == entry.id
        let isHost = challenge.currentUserMode == .host || challenge.hostUserID == currentUserID
        let hasVotedThisEntry = challenge.recordedVotedEntryIDs.contains(entry.id)
        ownBadgeLabel.isHidden = !isOwnEntry

        if isOwnEntry {
            backgroundColor = LirauCommunityPalette.elevated
            layer.borderWidth = 1.5
            layer.borderColor = LirauCommunityPalette.purpleLight.withAlphaComponent(0.7).cgColor
            nameButton.setTitle("You", for: .normal)
        } else {
            backgroundColor = LirauCommunityPalette.card
            layer.borderWidth = 1
            layer.borderColor = UIColor.white.withAlphaComponent(0.08).cgColor
        }

        if challenge.phase == .ended {
            voteButton.isHidden = true
            voteButton.isEnabled = false
            voteButton.alpha = 1
            return
        }

        voteButton.isHidden = false
        if isHost {
            voteButton.setTitle("Host", for: .normal)
            voteButton.isEnabled = false
        } else if isOwnEntry {
            voteButton.setTitle("Your entry", for: .normal)
            voteButton.isEnabled = false
        } else if hasVotedThisEntry {
            voteButton.setTitle("Voted", for: .normal)
            voteButton.isEnabled = false
        } else if challenge.status == .live || challenge.status == .voting {
            voteButton.setTitle("Vote", for: .normal)
            voteButton.isEnabled = true
        } else {
            voteButton.setTitle("Closed", for: .normal)
            voteButton.isEnabled = false
        }
        voteButton.alpha = voteButton.isEnabled ? 1 : 0.62
        voteButton.gradientColors = voteButton.isEnabled
            ? [LirauCommunityPalette.purpleLight, LirauCommunityPalette.purple]
            : [UIColor.white.withAlphaComponent(0.2), UIColor.white.withAlphaComponent(0.1)]
    }

    private func buildCard() {
        applyLirauCommunityChrome(cornerRadius: 20, borderAlpha: 0.08, shadowAlpha: 0.12)

        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.spacing = 11
        stack.layoutMargins = UIEdgeInsets(top: 15, left: 15, bottom: 15, right: 15)
        stack.isLayoutMarginsRelativeArrangement = true
        addSubview(stack)

        let header = UIStackView()
        header.axis = .horizontal
        header.alignment = .center
        header.spacing = 10

        avatarView.translatesAutoresizingMaskIntoConstraints = false
        avatarView.layer.cornerRadius = 21
        avatarView.layer.borderWidth = 1.5
        avatarView.layer.borderColor = UIColor.white.withAlphaComponent(0.16).cgColor
        avatarView.clipsToBounds = true
        avatarView.contentMode = .scaleAspectFill

        nameButton.contentHorizontalAlignment = .left
        nameButton.setTitleColor(.white, for: .normal)
        nameButton.titleLabel?.font = .systemFont(ofSize: 14, weight: .bold)
        nameButton.addTarget(self, action: #selector(profileTapped), for: .touchUpInside)

        ownBadgeLabel.text = "YOUR ENTRY"
        ownBadgeLabel.textAlignment = .center
        ownBadgeLabel.textColor = .white
        ownBadgeLabel.font = .systemFont(ofSize: 10, weight: .black)
        ownBadgeLabel.backgroundColor = LirauCommunityPalette.purpleLight.withAlphaComponent(0.24)
        ownBadgeLabel.layer.borderWidth = 1
        ownBadgeLabel.layer.borderColor = LirauCommunityPalette.purpleLight.withAlphaComponent(0.28).cgColor
        ownBadgeLabel.layer.cornerRadius = 9
        ownBadgeLabel.clipsToBounds = true
        ownBadgeLabel.isHidden = true

        accentLabel.font = .systemFont(ofSize: 11, weight: .medium)
        accentLabel.textColor = LirauCommunityPalette.dimText

        let titleRow = UIStackView(arrangedSubviews: [nameButton, ownBadgeLabel])
        titleRow.axis = .horizontal
        titleRow.spacing = 8
        titleRow.alignment = .center

        let nameStack = UIStackView(arrangedSubviews: [titleRow, accentLabel])
        nameStack.axis = .vertical
        nameStack.spacing = 2

        reportButton.backgroundColor = nil
        reportButton.layer.cornerRadius = 14
        reportButton.tintColor = LirauCommunityPalette.purple
        reportButton.setImage(UIImage(systemName: "exclamationmark.bubble.fill"), for: .normal)
        reportButton.addTarget(self, action: #selector(reportTapped), for: .touchUpInside)

        header.addArrangedSubview(avatarView)
        header.addArrangedSubview(nameStack)
        header.addArrangedSubview(reportButton)

        sentenceLabel.font = .systemFont(ofSize: 14.5, weight: .bold)
        sentenceLabel.textColor = .white
        sentenceLabel.numberOfLines = 0

        translationLabel.font = .systemFont(ofSize: 12, weight: .medium)
        translationLabel.textColor = LirauCommunityPalette.mutedText
        translationLabel.numberOfLines = 0

        entryMetricsLabel.font = .systemFont(ofSize: 11.5, weight: .semibold)
        entryMetricsLabel.textColor = LirauCommunityPalette.dimText
        entryMetricsLabel.numberOfLines = 2

        voteButton.setTitleColor(.white, for: .normal)
        voteButton.titleLabel?.font = .systemFont(ofSize: 13, weight: .bold)
        voteButton.addTarget(self, action: #selector(voteTapped), for: .touchUpInside)
        voteButton.setContentCompressionResistancePriority(.required, for: .horizontal)

        let footerRow = UIStackView(arrangedSubviews: [entryMetricsLabel, voteButton])
        footerRow.axis = .horizontal
        footerRow.alignment = .center
        footerRow.spacing = 12

        stack.addArrangedSubview(header)
        stack.addArrangedSubview(sentenceLabel)
        stack.addArrangedSubview(translationLabel)
        stack.addArrangedSubview(footerRow)

        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: topAnchor),
            stack.leadingAnchor.constraint(equalTo: leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: trailingAnchor),
            stack.bottomAnchor.constraint(equalTo: bottomAnchor),
            avatarView.widthAnchor.constraint(equalToConstant: 42),
            avatarView.heightAnchor.constraint(equalToConstant: 42),
            ownBadgeLabel.heightAnchor.constraint(equalToConstant: 18),
            ownBadgeLabel.widthAnchor.constraint(greaterThanOrEqualToConstant: 76),
            reportButton.widthAnchor.constraint(equalToConstant: 28),
            reportButton.heightAnchor.constraint(equalToConstant: 28),
            voteButton.heightAnchor.constraint(equalToConstant: 36),
            voteButton.widthAnchor.constraint(greaterThanOrEqualToConstant: 86)
        ])
    }

    @objc private func voteTapped() {
        onVote?()
    }

    @objc private func reportTapped() {
        onReport?()
    }

    @objc private func profileTapped() {
        onProfile?()
    }
}
